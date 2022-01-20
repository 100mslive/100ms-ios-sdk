Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '0.2.5'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live' }
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/0.2.5/HMSSDK.xcframework.zip',
                           :sha256 => 'b61c0dc9766c538a8c47e6f28215fd6f0c2c6fec0353e9ad329a9631109d17e9'
						}
  s.ios.deployment_target = '10.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.4518'
 
end
