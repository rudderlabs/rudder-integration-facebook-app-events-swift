//
//  RSFacebookAppEventsDestination.swift
//  RudderFacebookAppEvents
//
//  Created by Pallab Maiti on 04/03/22.
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Foundation
import Rudder
import FBSDKCoreKit

class RSFacebookAppEventsDestination: RSDestinationPlugin {
    let type = PluginType.destination
    let key = "Facebook App Events"
    var client: RSClient?
    var controller = RSController()
    
    func update(serverConfig: RSServerConfig, type: UpdateType) {
        guard type == .initial else { return }
        guard let facebookAppEventsConfig: RudderFacebookAppEventsConfig = serverConfig.getConfig(forPlugin: self) else {
            client?.log(message: "Failed to Initialize Facebook App Events Factory", logLevel: .warning)
            return
        }
        var dpoState = facebookAppEventsConfig.dpoState
        if facebookAppEventsConfig.dpoState != 0, facebookAppEventsConfig.dpoState != 1000 {
            dpoState = 0
        }
        var dpoCountry = facebookAppEventsConfig.dpoCountry
        if dpoCountry != 0, dpoCountry != 1 {
            dpoCountry = 0
        }
        let limitedDataUse = facebookAppEventsConfig.limitedDataUse
        if limitedDataUse == true {
            Settings.shared.setDataProcessingOptions(["LDU"], country: Int32(dpoCountry), state: Int32(dpoState))
            client?.log(message: "[FBSDKSettings setDataProcessingOptions:[LDU] country:\(dpoCountry) state:\(dpoState)]", logLevel: .debug)
        } else {
            Settings.shared.setDataProcessingOptions([])
            client?.log(message: "[FBSDKSettings setDataProcessingOptions:[]]", logLevel: .debug)
        }
        if client?.configuration?.logLevel == RSLogLevel.debug || client?.configuration?.logLevel == RSLogLevel.verbose {
            Settings.shared.enableLoggingBehavior(.appEvents)
        }
        client?.log(message: "Initializing Facebook App Events SDK", logLevel: .debug)
    }
    
    func identify(message: IdentifyMessage) -> IdentifyMessage? {
        if let userId = message.userId {
            AppEvents.shared.userID = message.userId
        }
        AppEvents.shared.setUser(
            email: message.traits?[RSKeys.Identify.Traits.email] as? String,
            firstName: message.traits?[RSKeys.Identify.Traits.firstName] as? String,
            lastName: message.traits?[RSKeys.Identify.Traits.lastName] as? String,
            phone: message.traits?[RSKeys.Identify.Traits.phone] as? String,
            dateOfBirth: message.traits?[RSKeys.Identify.Traits.birthday] as? String,
            gender: message.traits?[RSKeys.Identify.Traits.gender] as? String,
            city: message.traits?[RSKeys.Identify.Traits.Address.city] as? String,
            state: message.traits?[RSKeys.Identify.Traits.Address.state] as? String,
            zip: message.traits?[RSKeys.Identify.Traits.Address.postalcode] as? String,
            country: message.traits?[RSKeys.Identify.Traits.Address.country] as? String
        )
        return message
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        let index = message.event.index(message.event.startIndex, offsetBy: min(40, message.event.count))
        let truncatedEvent = String(message.event[..<index])
        var params = [AppEvents.ParameterName: Any]()
        handleCustom(properties: message.properties, params: &params)
        let eventName = getFacebookEvent(from: truncatedEvent)
        switch eventName {
        case AppEvents.Name.addedToCart, AppEvents.Name.addedToWishlist, AppEvents.Name.viewedContent:
            handleStandard(properties: message.properties, params: &params, eventName: eventName)
            if let properties = message.properties, let price = RSFacebookAppEventsDestination.extractValutToSum(from: properties, valueToSumKey: RSKeys.Ecommerce.price)  {
                AppEvents.shared.logEvent(eventName, valueToSum: price, parameters: params)
            }
        case AppEvents.Name.initiatedCheckout, AppEvents.Name.spentCredits:
            handleStandard(properties: message.properties, params: &params, eventName: eventName)
            if let properties = message.properties, let value = RSFacebookAppEventsDestination.extractValutToSum(from: properties, valueToSumKey: RSKeys.Ecommerce.value) {
                AppEvents.shared.logEvent(eventName, valueToSum: value, parameters: params)
            }
        case AppEvents.Name.purchased:
            handleStandard(properties: message.properties, params: &params, eventName: eventName)
            if let properties = message.properties, let revenue = RSFacebookAppEventsDestination.extractValutToSum(from: properties, valueToSumKey: RSKeys.Ecommerce.revenue), let currency = properties[RSKeys.Ecommerce.currency] as? String {
                AppEvents.shared.logPurchase(amount: revenue, currency: currency, parameters: params)
            }
        case AppEvents.Name.searched, AppEvents.Name.addedPaymentInfo, AppEvents.Name.completedRegistration, AppEvents.Name.achievedLevel, AppEvents.Name.completedTutorial, AppEvents.Name.unlockedAchievement, AppEvents.Name.subscribe, AppEvents.Name.startTrial, AppEvents.Name.adClick, AppEvents.Name.adImpression, AppEvents.Name.rated:
            handleStandard(properties: message.properties, params: &params, eventName: eventName)
            AppEvents.shared.logEvent(eventName, parameters: params)
            // Custom events
        default:
            AppEvents.shared.logEvent(eventName, parameters: params)
            break
        }
        return message
    }
    
    func screen(message: ScreenMessage) -> ScreenMessage? {
        // FB Event Names must be <= 40 characters
        // 'Viewed' and 'Screen' with spaces take up 14
        let index = message.name.index(message.name.startIndex, offsetBy: min(26, message.name.count))
        let truncatedEvent = String(message.name[..<index])
        var params = [AppEvents.ParameterName: Any]()
        handleCustom(properties: message.properties, params: &params)
        AppEvents.shared.logEvent(AppEvents.Name(rawValue: "Viewed \(truncatedEvent) Screen"), parameters: params)
        return message
    }
    
    func reset() {
        AppEvents.shared.clearUserData()
        AppEvents.shared.userID = nil
    }
}

extension RSFacebookAppEventsDestination: RSiOSLifecycle {
    func applicationDidBecomeActive(application: UIApplication?) {
        ApplicationDelegate.shared.initializeSDK()
    }
}

// MARK: - Support methods

extension RSFacebookAppEventsDestination {
    var TRACK_RESERVED_KEYWORDS: [String] {
        return [RSKeys.Ecommerce.productId, RSKeys.Ecommerce.rating, RSKeys.Ecommerce.promotionName, RSKeys.Ecommerce.orderId, RSKeys.Ecommerce.currency, RSKeys.Other.description, RSKeys.Ecommerce.query, RSKeys.Ecommerce.value, RSKeys.Ecommerce.price, RSKeys.Ecommerce.revenue]
    }
    
    func getFacebookEvent(from event: String) -> AppEvents.Name {
        switch event {
        case RSEvents.Ecommerce.productsSearched: return AppEvents.Name.searched
        case RSEvents.Ecommerce.productViewed: return AppEvents.Name.viewedContent
        case RSEvents.Ecommerce.productAdded: return AppEvents.Name.addedToCart
        case RSEvents.Ecommerce.productAddedToWishList: return AppEvents.Name.addedToWishlist
        case RSEvents.Ecommerce.paymentInfoEntered: return AppEvents.Name.addedPaymentInfo
        case RSEvents.Ecommerce.checkoutStarted: return AppEvents.Name.initiatedCheckout
        case RSEvents.Ecommerce.orderCompleted: return AppEvents.Name.purchased
        case RSEvents.LifeCycle.completeRegistration: return AppEvents.Name.completedRegistration
        case RSEvents.LifeCycle.achieveLevel: return AppEvents.Name.achievedLevel
        case RSEvents.LifeCycle.completeTutorial: return AppEvents.Name.completedTutorial
        case RSEvents.LifeCycle.unlockAchievement: return AppEvents.Name.unlockedAchievement
        case RSEvents.LifeCycle.subscribe: return AppEvents.Name.subscribe
        case RSEvents.LifeCycle.startTrial: return AppEvents.Name.startTrial
        case RSEvents.Ecommerce.promotionClicked: return AppEvents.Name.adClick
        case RSEvents.Ecommerce.promotionViewed: return AppEvents.Name.adImpression
        case RSEvents.Ecommerce.spendCredits: return AppEvents.Name.spentCredits
        case RSEvents.Ecommerce.productReviewed: return AppEvents.Name.rated
        default: return AppEvents.Name(rawValue: event)
        }
    }
    
    func handleStandard(properties properties: [String: Any]?, params: inout [AppEvents.ParameterName: Any], eventName: AppEvents.Name){
        guard let properties = properties else {
            return
        }
        
        if let productId = properties[RSKeys.Ecommerce.productId] {
            params[AppEvents.ParameterName.contentID] = "\(productId)"
        }
        if let rating = properties[RSKeys.Ecommerce.rating] as? Int {
            params[AppEvents.ParameterName.maxRatingValue] = rating
        }
        if let name = properties[RSKeys.Ecommerce.promotionName] {
            params[AppEvents.ParameterName.adType] = "\(name)"
        }
        if let orderId = properties[RSKeys.Ecommerce.orderId] {
            params[AppEvents.ParameterName.orderID] = "\(orderId)"
        }
        /// For `Purchase` event we're directly handling the `currency` properties
        if eventName != AppEvents.Name.purchased {
            if let currency = properties[RSKeys.Ecommerce.currency] {
                params[AppEvents.ParameterName.currency] = "\(currency)"
            }
        }
        if let description = properties[RSKeys.Other.description] {
            params[AppEvents.ParameterName.description] = "\(description)"
        }
        if let query = properties[RSKeys.Ecommerce.query] {
            params[AppEvents.ParameterName.searchString] = "\(query)"
        }
    }
    
    func handleCustom(_ properties: [String: Any]?, params: inout [AppEvents.ParameterName: Any]){
        guard let properties = properties else {
            return
        }
        
        for (key, value) in properties {
            if TRACK_RESERVED_KEYWORDS.contains(key) {
                continue
            }
            params[AppEvents.ParameterName(rawValue: key)] = "\(value)"
        }
    }
    
    static func extractValutToSum(from properties: [String: Any]?, valueToSumKey: String) -> Double? {
        if let properties = properties {
            for key in properties.keys {
                if key.caseInsensitiveCompare(valueToSumKey) == .orderedSame {
                    if let valueToSum = properties[key] {
                        return Double("\(valueToSum)")
                    }
                    break
                }
            }
        }
        return nil
    }
}

struct RudderFacebookAppEventsConfig: Codable {
    private let _dpoState: String?
    var dpoState: Int {
        return (_dpoState as? Int) ?? 0
    }
    
    private let _dpoCountry: String?
    var dpoCountry: Int {
        return (_dpoCountry as? Int) ?? 0
    }
    
    private let _limitedDataUse: Bool?
    var limitedDataUse: Bool {
        return _limitedDataUse ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case _dpoState = "dpoState"
        case _dpoCountry = "dpoCountry"
        case _limitedDataUse = "limitedDataUse"
    }
}

@objc
public class RudderFacebookAppEventsDestination: RudderDestination {
    
    public override init() {
        super.init()
        plugin = RSFacebookAppEventsDestination()
    }
}
#endif
