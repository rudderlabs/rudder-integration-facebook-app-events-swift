source 'https://github.com/CocoaPods/Specs.git'
workspace 'RudderFacebookAppEvents.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '12.0'


target 'RudderFacebookAppEvents' do
    project 'RudderFacebookAppEvents.xcodeproj'
    pod 'Rudder', '~> 2.0'
    pod 'FBSDKCoreKit', '14.0.0'
end

target 'SampleAppObjC' do
    project 'Examples/SampleAppObjC/SampleAppObjC.xcodeproj'
    pod 'RudderFacebookAppEvents', :path => '.'
end

target 'SampleAppSwift' do
    project 'Examples/SampleAppSwift/SampleAppSwift.xcodeproj'
    pod 'RudderFacebookAppEvents', :path => '.'
end
