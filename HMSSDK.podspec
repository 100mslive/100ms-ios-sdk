Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '1.17.1'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/1.17.1/HMSSDK.xcframework.zip',
                           :sha256 => '3f24797f5e49e53d4cbe807e4a59ebcbaf2676a701e99f0cc11ca67e2c4edfae'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.6174'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
