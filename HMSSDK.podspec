Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '1.16.7'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/1.16.7/HMSSDK.xcframework.zip',
                           :sha256 => '67228edf837f6a2d7818e4b3ae1d2245ad625392f765f72de6c8024eceec5033'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.6172'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
