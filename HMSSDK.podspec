Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '0.2.2'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live' }
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/0.2.2/HMSSDK.xcframework.zip',
                           :sha256 => 'c2ad22fe09496673dbf41e2291d931d56b23bf8741aca20331eb61487b8f8396'
						}
  s.ios.deployment_target = '10.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.4516'
 
end
