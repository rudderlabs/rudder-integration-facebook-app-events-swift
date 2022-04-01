source 'https://github.com/CocoaPods/Specs.git'
workspace 'RudderFacebookAppEvents.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '12.0'

def shared_pods
    pod 'RudderStack', :path => '~/Documents/Rudder/RudderStack-Swift/'
end

target 'RudderFacebookAppEvents' do
    project 'RudderFacebookAppEvents.xcodeproj'
    shared_pods
    pod 'FBSDKCoreKit', '13.0.0'
end

target 'SampleAppObjC' do
    project 'Examples/SampleAppObjC/SampleAppObjC.xcodeproj'
    shared_pods
    pod 'RudderFacebookAppEvents', :path => '.'
end

target 'SampleAppSwift' do
    project 'Examples/SampleAppSwift/SampleAppSwift.xcodeproj'
    shared_pods
    pod 'RudderFacebookAppEvents', :path => '.'
end
