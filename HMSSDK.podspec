Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '0.2.18'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live' }
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/0.2.18/HMSSDK.xcframework.zip',
                           :sha256 => 'e1729e45d2ffa9f38c86e8e2597b0a0c08f24bd376b7a1cd74fe4dbc680b23ad'
						}
  s.ios.deployment_target = '10.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.4518'
 
end
