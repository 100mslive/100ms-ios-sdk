Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '0.1.4'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live' }
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/0.1.4/HMSSDK.xcframework.zip',
                           :sha256 => '414d22f478cfdc24432a3d10a01374d313dfd05d5c5283ebe6d0fd27f7afeae6'
						}
  s.ios.deployment_target = '10.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.4516'
 
end
