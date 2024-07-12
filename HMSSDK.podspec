Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '1.14.1'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/1.14.1/HMSSDK.xcframework.zip',
                           :sha256 => '9949413d443492b01cca4060b6425cdf31814712127b25d2bd24ebf535e0e09e'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.6170'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
