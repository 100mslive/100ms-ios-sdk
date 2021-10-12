Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '0.1.3'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live' }
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/0.1.3/HMSSDK.xcframework.zip',
                           :sha256 => 'a74320df850ab410426c6a6ceeb04bb3d0c90842e55f2764f099cd2ace4fb378'
						}
  s.ios.deployment_target = '10.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.4516'
 
end
