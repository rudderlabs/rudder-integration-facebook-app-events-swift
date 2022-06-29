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
    
    /*
     Ad Type:     FBSDKAppEventParameterNameAdType
     Content: FBSDKAppEventParameterNameContent
     Content ID:     FBSDKAppEventParameterNameContentID (String)
     Content Type:     FBSDKAppEventParameterNameContentType
     Currency:     FBSDKAppEventParameterNameCurrency (String: ISO 4217 code, for example, EUR, USD, JPY)
     Description: FBSDKAppEventParameterNameDescription
     Level:     FBSDKAppEventParameterNameLevel
     Max. Rating Value:     FBSDKAppEventParameterNameMaxRatingValue (INT)
     Number of Items:     FBSDKAppEventParameterNameNumItems (INT)
     Order ID:     FBSDKAppEventParameterNameOrderID (String)
     Payment Info Available:     FBSDKAppEventParameterNamePaymentInfoAvailable (Boolean)
     Registration Method:     FBSDKAppEventParameterNameRegistrationMethod (String)
     Search String:     FBSDKAppEventParameterNameSearchString (String)
     Success:     FBSDKAppEventParameterNameSuccess (Boolean)
     
     */
    
    func track(message: TrackMessage) -> TrackMessage? {
//        AppEvents.shared.logEvent(AppEvents.Name.searched)
        
//        let ev: String = "myTestEvent3"
//        let eventName: AppEvents.Name = AppEvents.Name(rawValue: ev)
//        AppEvents.shared.logEvent(eventName)
        
        
        let index = message.event.index(message.event.startIndex, offsetBy: min(40, message.event.count))
        let truncatedEvent = String(message.event[..<index])
        var params = [AppEvents.ParameterName: Any]()
        switch getFacebookEvent(from: truncatedEvent) {
//        case AppEvents.Name.searched:   // RSEvents.Ecommerce.productsSearched:
//            if let properties = message.properties {
//                params[AppEvents.ParameterName.contentType] = properties["contentType"]
////                params[AppEvents.ParameterName(rawValue: "abc")] = "asl"
//                params[AppEvents.ParameterName.searchString] = properties["query"]
//                AppEvents.shared.logEvent(AppEvents.Name.searched, parameters: params)
//            }
//        case AppEvents.Name.viewedContent: //RSEvents.Ecommerce.productViewed:
        case AppEvents.Name.addedToCart: //RSEvents.Ecommerce.productAdded:
        case AppEvents.Name.addedToWishlist: //RSEvents.Ecommerce.productAddedToWishList:
        case AppEvents.Name.addedPaymentInfo: //RSEvents.Ecommerce.paymentInfoEntered:
        case AppEvents.Name.initiatedCheckout: //RSEvents.Ecommerce.checkoutStarted:
        case AppEvents.Name.purchased: //RSEvents.Ecommerce.orderCompleted:
        case AppEvents.Name.completedRegistration: //RSEvents.LifeCycle.completeRegistration:
        case AppEvents.Name.achievedLevel: //RSEvents.LifeCycle.achieveLevel:
        case AppEvents.Name.completedTutorial: //RSEvents.LifeCycle.completeTutorial:
        case AppEvents.Name.unlockedAchievement: //RSEvents.LifeCycle.unlockAchievement:
        case AppEvents.Name.adClick: //RSEvents.Ecommerce.promotionClicked:
        case AppEvents.Name.spentCredits: //RSEvents.Ecommerce.spendCredits:
        default:
            break
        }
//        if let revenue = RSFacebookAppEventsDestination.extractRevenue(from: message.properties, revenueKey: RSKeys.Ecommerce.revenue) {
//            let currency = RSFacebookAppEventsDestination.extractCurrency(from: message.properties, withKey: RSKeys.Ecommerce.currency)
//            var properties = message.properties
//            properties?[RSKeys.Ecommerce.currency] = currency
//            AppEvents.shared.logPurchase(amount: revenue, currency: currency, parameters: RSFacebookAppEventsDestination.extractParams(properties: properties))
//            AppEvents.shared.logEvent(AppEvents.Name(truncatedEvent), valueToSum: revenue, parameters: RSFacebookAppEventsDestination.extractParams(properties: properties))
//        } else {
//            AppEvents.shared.logEvent(AppEvents.Name(truncatedEvent), parameters: RSFacebookAppEventsDestination.extractParams(properties: message.properties))
//        }
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
    /*
     "Products Searched": "fb_mobile_search", ->  // Search
       "Product Viewed": "fb_mobile_content_view",  // Content View
       "Product Added": "fb_mobile_add_to_cart", // Add to Cart
       "Product Added to Wishlist": "fb_mobile_add_to_wishlist", // Add to Wishlist
       "Payment Info Entered": "fb_mobile_add_payment_info", // Add Payment Info
       "Checkout Started": "fb_mobile_initiated_checkout", // Initiate Checkout
       "Order Completed": "fb_mobile_purchase" // Purchase
     
     Standard Events:
     Add Payment Info, Add to Cart, Add to WishList, Complete Registration, Content View, Initiated Checkout, Level Achieved, Purchase, Spent Credits, Tutorial Completion, Achievement Unlocked, Search
     Rate, Subscribe, Start Trial
     
     Achieve Level, Activate App, In-App Ad Click, In-App Ad Impression, Add Payment Info, Add to Cart, Add to Wishlist, Complete Registration, Complete Tutorial, Contact, Customize Product, Donate, Find Location, Initiate Checkout, logPurchase, Rate, Schedule, Search, Spent Credits, Start Trial, Submit Application, Subscribe, Subscription, Unlock Achievement, View Content
     
     
     These events are not implemented: Subscription, Submit Application,  Schedule, Find Location, Donate, Customize Product, Contact,
     */
    
    func getFacebookEvent(from event: String) -> AppEvents.Name {
        switch event {
//        case RSEvents.Ecommerce.productsSearched:
//            return AppEvents.Name.searched
//        case RSEvents.Ecommerce.productViewed:
//            return AppEvents.Name.viewedContent
//        case RSEvents.Ecommerce.productAdded:
//            return AppEvents.Name.addedToCart
//        case RSEvents.Ecommerce.productAddedToWishList:
//            return AppEvents.Name.addedToWishlist
//        case RSEvents.Ecommerce.paymentInfoEntered:
//            return AppEvents.Name.addedPaymentInfo
//        case RSEvents.Ecommerce.checkoutStarted:
//            return AppEvents.Name.initiatedCheckout
//        case RSEvents.Ecommerce.orderCompleted:
//            return AppEvents.Name.purchased
            
//        case RSEvents.LifeCycle.completeRegistration:
//            return AppEvents.Name.completedRegistration
//        case RSEvents.LifeCycle.achieveLevel:
//            return AppEvents.Name.achievedLevel
//        case RSEvents.LifeCycle.completeTutorial:
//            return AppEvents.Name.completedTutorial
//        case RSEvents.LifeCycle.unlockAchievement:
//            return AppEvents.Name.unlockedAchievement
//        case "subscribe":
//            return AppEvents.Name.subscribe
//        case "start trial":
//            return AppEvents.Name.startTrial
            
        case RSEvents.Ecommerce.promotionClicked:
            return AppEvents.Name.adClick
            // TODO: Checn if below mapping is correct or not
        case RSEvents.Ecommerce.promotionViewed:
            return AppEvents.Name.adImpression
        case RSEvents.Ecommerce.spendCredits:
            return AppEvents.Name.spentCredits
        case RSEvents.Ecommerce.productReviewed:
            return AppEvents.Name.rated
        
            
        default:
            return AppEvents.Name(rawValue: event)
        }
    }
    
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
