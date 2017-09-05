target 'MusiqueDataEntry'
use_frameworks!

pod 'Eureka'
pod 'SDWebImage'
pod 'Firebase', '>= 2.5.1'
pod 'Firebase/Database'
pod 'Firebase/Core'
pod 'Alamofire'
pod 'ObjectMapper'
pod 'XCDYouTubeKit', :git => 'https://github.com/ML-Works/XCDYouTubeKit.git', :branch => 'feature/referer'
pod 'YelpAPI'
pod 'SlideMenuControllerSwift'
pod 'Google/SignIn'
pod 'GoogleAPIClientForREST/Calendar'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
