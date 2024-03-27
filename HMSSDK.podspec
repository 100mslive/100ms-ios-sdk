Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '1.8.0'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/1.8.0/HMSSDK.xcframework.zip',
                           :sha256 => 'bb9e0330b0db6c555e669e1529ade0e0e1362ca107b85c1f93910b5239b8f56e'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.5118'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
