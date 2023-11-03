Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '1.2.0'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/1.2.0/HMSSDK.xcframework.zip',
                           :sha256 => '1c1b6ca759aad9b67a55e97e60b97fe724989631466b74e0db5a7dc06ebc2364'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.5116'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
