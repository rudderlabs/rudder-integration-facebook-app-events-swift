# What is RudderStack?

[RudderStack](https://rudderstack.com/) is a **customer data pipeline** tool for collecting, routing and processing data from your websites, apps, cloud tools, and data warehouse.

More information on RudderStack can be found [here](https://github.com/rudderlabs/rudder-server).

## Integrating Facebook with RudderStack's iOS SDK

1. Add [Facebook](http://Facebook.google.com) as a destination in the [Dashboard](https://app.rudderstack.com/).

2. Rudder-Facebook is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your Podfile and followed by `pod install`:

```ruby
pod 'RudderFacebookAppEvents'
```

## Initialize ```RSClient```

Put the following code in your ```AppDelegate.m``` file under the method ```didFinishLaunchingWithOptions```:

```
RSConfig *config = [[RSConfig alloc] initWithWriteKey:WRITE_KEY];
[config dataPlaneURL:DATA_PLANE_URL];    
RSClient *client = [[RSClient alloc] initWithConfig:config];
[client addWithDestination:[[RudderFacebookAppEventsDestination alloc] init]];
```

## Send Events
Follow the steps from the [RudderStack iOS SDK](https://github.com/rudderlabs/rudder-sdk-cocoa).

## Contact Us

If you come across any issues while configuring or using this integration, please feel free to [start a conversation on our [Slack](https://resources.rudderstack.com/join-rudderstack-slack) channel. We will be happy to help you.
