Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '0.2.16'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live' }
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/0.2.16/HMSSDK.xcframework.zip',
                           :sha256 => 'dd7d8df08cefea37b7e5c0c43d414308746d248e74eefad2394084885b81698a'
						}
  s.ios.deployment_target = '10.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.4518'
 
end
