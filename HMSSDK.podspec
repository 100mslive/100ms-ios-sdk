Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '1.16.5'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/1.16.5/HMSSDK.xcframework.zip',
                           :sha256 => 'b880c717e91c819b4d0505b62108c1f7a18ab044b089d2d81f80f12bafb5a3c8'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.6172'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
