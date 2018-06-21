# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'HuntedRadar' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HuntedRadar
pod 'FMDB'
pod 'SwiftLint'
pod 'Alamofire'
pod 'Charts'
pod 'Firebase/Core'
pod 'Firebase/Database'
pod 'FirebaseUI/Auth'
pod 'Firebase/Storage'
pod 'SDWebImage'
pod 'IQKeyboardManagerSwift'
pod 'SwipeCellKit'
pod 'SVProgressHUD'
pod 'Fabric'
pod 'Crashlytics'


end

target 'HuntedRadarModelTests' do
    inherit! :search_paths
    pod ‘Firebase’
    end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings.delete('CODE_SIGNING_ALLOWED')
            config.build_settings.delete('CODE_SIGNING_REQUIRED')
        end
    end
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
