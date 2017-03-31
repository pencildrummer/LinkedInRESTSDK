#
# Be sure to run `pod lib lint LinkedInRESTSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LinkedInRESTSDK'
  s.version          = '0.1.1'
  s.summary          = 'A short description of LinkedInRESTSDK.'

  s.homepage         = 'https://github.com/pencildrummer/LinkedInRESTSDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Fabio Borella' => 'info@pencildrummer.com' }
  s.source           = { :git => 'https://github.com/pencildrummer/LinkedInRESTSDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'LinkedInRESTSDK/Classes/**/*'

  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'AlamofireObjectMapper'

end
