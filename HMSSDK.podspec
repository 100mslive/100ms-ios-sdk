Pod::Spec.new do |s|
  s.name             = 'HMSSDK'
  s.version          = '1.9.0'
  s.summary          = 'HMS Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios-sdk/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live', 'Yogesh Singh' => 'yogesh@100ms.live', 'Pawan Dixit' => 'pawan@100ms.live'}
  s.source           = { :http => 'https://github.com/100mslive/100ms-ios-sdk/releases/download/1.9.0/HMSSDK.xcframework.zip',
                           :sha256 => '91956dcef75fca86290c9c810a6d2c6565435fc49ab04d0a2ee9b1ce4003bc34'
						}
  s.ios.deployment_target = '12.0'
  s.vendored_frameworks = 'HMSSDK.xcframework'
  
  s.dependency 'HMSWebRTC', '1.0.6168'
  s.dependency 'HMSAnalyticsSDK', '0.0.2'
 
end
