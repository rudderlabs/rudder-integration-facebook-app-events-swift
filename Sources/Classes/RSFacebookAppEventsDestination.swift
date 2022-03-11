//
//  RSFacebookAppEventsDestination.swift
//  RudderFacebookAppEvents
//
//  Created by Pallab Maiti on 04/03/22.
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Foundation
import RudderStack
import FBSDKCoreKit

class RSFacebookAppEventsDestination: RSDestinationPlugin {
    let type = PluginType.destination
    let key = "Facebook App Events"
    var client: RSClient?
    var controller = RSController()
        
    func update(serverConfig: RSServerConfig, type: UpdateType) {
        guard type == .initial else { return }
        if let destinations = serverConfig.destinations {
            if let destination = destinations.first(where: { $0.destinationDefinition?.displayName == self.key }) {
                let limitedDataUse = destination.config?.dictionaryValue?["limitedDataUse"] as? Bool
                var dpoState = destination.config?.dictionaryValue?["dpoState"] as? Int
                if dpoState != 0, dpoState != 1000 {
                    dpoState = 0
                }
                var dpoCountry = destination.config?.dictionaryValue?["dpoCountry"] as? Int
                if dpoCountry != 0, dpoCountry != 1 {
                    dpoCountry = 0
                }
                if limitedDataUse == true, let country = dpoCountry, let state = dpoState {
                    Settings.shared.setDataProcessingOptions(["LDU"], country: Int32(country), state: Int32(state))
                    client?.log(message: "[FBSDKSettings setDataProcessingOptions:[LDU] country:\(country) state:\(state)]", logLevel: .debug)
                } else {
                    Settings.shared.setDataProcessingOptions([])
                    client?.log(message: "[FBSDKSettings setDataProcessingOptions:[]]", logLevel: .debug)
                }
            }
        }
    }
    
    func identify(message: IdentifyMessage) -> IdentifyMessage? {
        AppEvents.shared.userID = message.userId
        AppEvents.shared.setUser(email: message.traits?["email"], firstName: message.traits?["firstName"], lastName: message.traits?["lastName"], phone: message.traits?["phone"], dateOfBirth: message.traits?["birthday"], gender: message.traits?["gender"], city: message.traits?["city"], state: message.traits?["state"], zip: message.traits?["postalcode"], country: message.traits?["country"])
        return message
    }
    
    func track(message: TrackMessage) -> TrackMessage? {
        let index = message.event.index(message.event.startIndex, offsetBy: min(40, message.event.count))
        let truncatedEvent = String(message.event[..<index])
        if let revenue = RSFacebookAppEventsDestination.extractRevenue(from: message.properties, revenueKey: "revenue") {
            let currency = RSFacebookAppEventsDestination.extractCurrency(from: message.properties, withKey: "currency")
            var properties = message.properties
            properties?["currency"] = currency
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
                case let v as NSString:
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
        case RSECommerceConstants.KeyCurrency: return AppEvents.ParameterName.currency
        case RSECommerceConstants.KeyOrderId: return AppEvents.ParameterName.orderID
        case RSECommerceConstants.KeyQuery: return AppEvents.ParameterName.searchString
        case RSECommerceConstants.KeyWishlistId: return AppEvents.ParameterName.contentID
        case RSECommerceConstants.KeyListId: return AppEvents.ParameterName.contentID
        case RSECommerceConstants.KeyCheckoutId: return AppEvents.ParameterName.contentID
        case RSECommerceConstants.KeyCouponId: return AppEvents.ParameterName.contentID
        case RSECommerceConstants.KeyCartId: return AppEvents.ParameterName.contentID
        case RSECommerceConstants.KeyReviewId: return AppEvents.ParameterName.contentID
        default: return AppEvents.ParameterName(rudderEvent)
        }
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
