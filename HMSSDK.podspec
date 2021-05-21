#
# Be sure to run `pod lib lint HMSVideo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '0.0.1'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live' }
  s.source           = { :git => 'https://github.com/100mslive/100ms-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'HMSSDK/HMSSDK.framework/Headers/*.h'
  s.public_header_files = 'HMSSDK/HMSSDK.framework/Headers/*.h'
  s.vendored_frameworks = 'HMSSDK/HMSSDK.framework'
  
  s.dependency 'GoogleWebRTC', '1.1.31999'
  s.pod_target_xcconfig = {
   'ENABLE_BITCODE' => 'NO',
   'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end
