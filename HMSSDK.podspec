Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '1.5.0'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/1.5.0/HMSSDK.xcframework.zip',
                           :sha256 => '9ba2a4d48eb0a1d4bd45f8ed2d17065e9f259fd4422da529fd2c633408c3a538'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.5116'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
