Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '0.8.1'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/0.8.1/HMSSDK.xcframework.zip',
                           :sha256 => '65aed4de27fef5cfd926db1abaec1100fe9c7eb3bc08ad313cc110b52acdbf16'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.5115'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
