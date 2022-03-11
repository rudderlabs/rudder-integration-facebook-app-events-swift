workspace 'RudderFacebookAppEvents.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '12.0'

def shared_pods
    pod 'RudderStack', :path => '~/Documents/Rudder/RudderStack-Cocoa/'
end

target 'SampleiOSObjC' do
    project 'Examples/SampleiOSObjC/SampleiOSObjC.xcodeproj'
    shared_pods
    pod 'RudderFacebookAppEvents', :path => '.'
end

target 'RudderFacebookAppEvents' do
    project 'RudderFacebookAppEvents.xcodeproj'
    shared_pods
    pod 'FBSDKCoreKit', '13.0.0'
end
