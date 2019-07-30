platform :ios, '11.0'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'ChatApp' do
	use_frameworks!
	
	pod 'Firebase/Core'
	pod 'Firebase/Auth'
	pod 'Firebase/Database'
	pod 'Firebase/Storage'
	pod 'Firebase/Messaging'
	pod 'NPTableAnimator', '~> 4.3.0'
	pod 'Kingfisher', '~> 5.3.1'
	pod 'lottie-ios', '~> 3.0.3'
	pod 'ReachabilitySwift', '4.3.0'
	
	#pod 'FacebookLogin', '0.4.0'
	pod 'FacebookLogin', :git => 'https://github.com/facebook/facebook-swift-sdk.git', :branch => 'swift-4.1'
	pod 'GoogleSignIn', '4.1.1'
	pod 'OpenSSL', '~> 1.0'

	
	#avoid apple warning about "Too many symbol files..."
	post_install do |installer|
		installer.pods_project.targets.each do |target|
			target.build_configurations.each do |config|
				config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
			end
		end
	end
	
end


