Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '1.15.0'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/1.15.0/HMSSDK.xcframework.zip',
                           :sha256 => '73f15409b76dc2a7b677027ede12fb5711f6222931f690b2701c6d86e0b3092b'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.6170'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
