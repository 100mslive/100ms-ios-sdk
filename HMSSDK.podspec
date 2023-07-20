Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '0.9.6'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/0.9.6/HMSSDK.xcframework.zip',
                           :sha256 => 'c8c0d06db1b3c7670b637ae1aff1d58271dc76f20899ff8881ac3deb5c3010ac'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.5116'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
