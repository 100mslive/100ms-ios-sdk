Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '1.16.8'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/1.16.8/HMSSDK.xcframework.zip',
                           :sha256 => 'fbaf0e7cd5802277d5f6e649f9adb8700411bb5cb0b1ff44794fd058f9e43693'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.6172'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
