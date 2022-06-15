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
            state: message.traits?["state"] as? String,
            zip: message.traits?["postalcode"] as? String,
            country: message.traits?[RSKeys.Identify.Traits.Address.country] as? String
        )
        return message
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        let index = message.event.index(message.event.startIndex, offsetBy: min(40, message.event.count))
        let truncatedEvent = String(message.event[..<index])
        if let revenue = RSFacebookAppEventsDestination.extractRevenue(from: message.properties, revenueKey: RSKeys.Ecommerce.revenue) {
            let currency = RSFacebookAppEventsDestination.extractCurrency(from: message.properties, withKey: RSKeys.Ecommerce.currency)
            var properties = message.properties
            properties?[RSKeys.Ecommerce.currency] = currency
            AppEvents.shared.logPurchase(amount: revenue, currency: currency, parameters: RSFacebookAppEventsDestination.extractParams(properties: properties))
            AppEvents.shared.logEvent(AppEvents.Name(truncatedEvent), valueToSum: revenue, parameters: RSFacebookAppEventsDestination.extractParams(properties: properties))
        } else {
            AppEvents.shared.logEvent(AppEvents.Name(truncatedEvent), parameters: RSFacebookAppEventsDestination.extractParams(properties: message.properties))
        }
        return message
    }
    
    func screen(message: ScreenMessage) -> ScreenMessage? {
        // FB Event Names must be <= 40 characters
        // 'Viewed' and 'Screen' with spaces take up 14
        let index = message.name.index(message.name.startIndex, offsetBy: min(26, message.name.count))
        let truncatedEvent = String(message.name[..<index])
        AppEvents.shared.logEvent(AppEvents.Name(rawValue: "Viewed \(truncatedEvent) Screen"), parameters: RSFacebookAppEventsDestination.extractParams(properties: message.properties))
        return message
    }
    
    func group(message: GroupMessage) -> GroupMessage? {
        client?.log(message: "MessageType is not supported", logLevel: .warning)
        return message
    }
    
    func alias(message: AliasMessage) -> AliasMessage? {
        client?.log(message: "MessageType is not supported", logLevel: .warning)
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
    static func extractRevenue(from properties: [String: Any]?, revenueKey: String) -> Double? {
        if let properties = properties {
            for key in properties.keys {
                if key.caseInsensitiveCompare(revenueKey) == .orderedSame {
                    if let revenue = properties[key] {
                        return Double("\(revenue)")
                    }
                    break
                }
            }
        }
        return nil
    }
    
    static func extractCurrency(from properties: [String: Any]?, withKey currencyKey: String) -> String {
        if let properties = properties {
            for key in properties.keys {
                if key.caseInsensitiveCompare(currencyKey) == .orderedSame {
                    if let currency = properties[key] {
                        return "\(currency)"
                    }
                    break
                }
            }
        }
        // default to USD
        return "USD"
    }
    
    static func extractParams(properties: [String: Any]?) -> [AppEvents.ParameterName: Any]? {
        var params: [AppEvents.ParameterName: Any]?
        if let properties = properties {
            params = [AppEvents.ParameterName: Any]()
            for (key, value) in properties {
                switch value {
                case let v as String:
                    params?[getFacebookAppEvent(from: key)] = v
                case let v as NSNumber:
                    params?[getFacebookAppEvent(from: key)] = v
                case let v as Bool:
                    params?[getFacebookAppEvent(from: key)] = v
                default:
                    break
                }
            }
        }
        return params
    }
    
    static func getFacebookAppEvent(from rudderEvent: String) -> AppEvents.ParameterName {
        switch rudderEvent {
        case RSKeys.Ecommerce.currency: return AppEvents.ParameterName.currency
        case RSKeys.Ecommerce.orderId: return AppEvents.ParameterName.orderID
        case RSKeys.Ecommerce.query: return AppEvents.ParameterName.searchString
        case RSKeys.Ecommerce.wishlistId: return AppEvents.ParameterName.contentID
        case RSKeys.Ecommerce.listId: return AppEvents.ParameterName.contentID
        case RSKeys.Ecommerce.checkoutId: return AppEvents.ParameterName.contentID
        case RSKeys.Ecommerce.couponId: return AppEvents.ParameterName.contentID
        case RSKeys.Ecommerce.cartId: return AppEvents.ParameterName.contentID
        case RSKeys.Ecommerce.reviewId: return AppEvents.ParameterName.contentID
        default: return AppEvents.ParameterName(rudderEvent)
        }
    }
}

struct RudderFacebookAppEventsConfig: Codable {
    private let _dpoState: Int?
    var dpoState: Int {
        return _dpoState ?? 0
    }
    
    private let _dpoCountry: Int?
    var dpoCountry: Int {
        return _dpoCountry ?? 0
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
