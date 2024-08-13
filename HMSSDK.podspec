Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '1.16.0'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/1.16.0/HMSSDK.xcframework.zip',
                           :sha256 => '50ff59448dc57d7611dec919b8e46196e091f9b4de70145c37882c6dd116f2a1'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.6170'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
