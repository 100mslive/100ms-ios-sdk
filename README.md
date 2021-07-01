<p align="center" >
  <a href="https://100ms.live/">
  <img src="https://github.com/100mslive/100ms-ios-sdk/blob/main/100ms-logo.png" title="100ms logo" float=left>
</p>

![Cocoapods](https://img.shields.io/cocoapods/v/HMSSDK)
![iOS](https://img.shields.io/badge/iOS-10.0%2B-yellow)
[![License](https://img.shields.io/cocoapods/l/HMSSDK.svg?style=flat)](http://cocoapods.org/pods/HMSSDK)
[![Documentation](https://img.shields.io/badge/Read-Documentation-blue)](https://docs.100ms.live/)
[![Slack](https://img.shields.io/badge/Community-Join%20on%20Slack-blue)](https://join.slack.com/t/100mslive/shared_invite/zt-llwdnz11-vkb2RzptwacwXHO7UeY0CQ)
[![Email](https://img.shields.io/badge/Contact-Know%20More-blue)](mailto:founders@100ms.live)

# 🎉 100ms SDK ＆ Sample App 🚀

Here you will find everything you need to build experiences with video using 100ms iOS SDK. Dive into our SDKs, quick starts, add real-time video, voice, and screen sharing to your web and mobile applications.
  
You can download the [Sample App via TestFlight here](https://testflight.apple.com/join/dhUSE7N8).

For running the Sample app locally, checkout the [ReadMe in Example folder](https://github.com/100mslive/100ms-ios-sdk/tree/main/Example).
  
## ☝️ Pre-requisites
- Xcode 12 or higher
- Support for iOS 10 or higher

## 🚂 Setup Guide
  
  1. Host your token generation service [following this guide](https://docs.100ms.live/v2/server-side/Generate-client-side-token)

  2. Get Access Keys: Sign up on https://dashboard.100ms.live/register & visit the Developer tab to get your access credentials

  3. Generate a server-side token, follow the steps described here - https://docs.100ms.live/v2/server-side/Generate-server-side-token

  4. Create a room, follow the steps described here - https://docs.100ms.live/v2/server-side/Create-room

  5. Generate a client-side token, follow the steps described here - https://docs.100ms.live/v2/server-side/Generate-client-side-token
  
  6. Get the HMSSDK via [Cocoapods](https://cocoapods.org/). Add the `pod 'HMSSDK'` to your Podfile as follows:
  ```
  // Podfile
  
  platform :ios, '10.0'

  target 'MyAwesomeApp' do
    pod 'HMSSDK'
  end
  ```

  
## 🧐 Key Concepts

- `Room` - A room represents real-time audio, video session, the basic building block of the 100mslive Video SDK
- `Track` - A track represents either the audio or video that makes up a stream
- `Peer` - A peer represents all participants connected to a room. Peers can be "local" or "remote"
- `Broadcast` - A local peer can send any message/data to all remote peers in the room 

## ♻️ Setup event listeners

100ms SDK provides callbacks to the client app about any change or update happening in the room after a user has joined by implementing `HMSUpdateListener`. These updates can be used to render the video on screen or to display other info regarding the room.

```
  protocol HMSUpdateListener {

  
    /// This will be called on a successful JOIN of the room by the user
    /// This is the point where applications can stop showing its loading state
    /// - Parameter room: the room which was joined
    func on(join room: HMSSDK.HMSRoom)

  
    /// This is called when there is a change in any property of the Room
    /// - Parameters:
    ///   - room: the room which was joined
    ///   - update: the triggered update type. Should be used to perform different UI Actions
    func on(room: HMSSDK.HMSRoom, update: HMSSDK.HMSRoomUpdate)

  
    /// This will be called whenever there is an update on an existing peer
    /// or a new peer got added/existing peer is removed.
    /// This callback can be used to keep a track of all the peers in the room
    /// - Parameters:
    ///   - peer: the peer who joined/left or was updated
    ///   - update: the triggered update type. Should be used to perform different UI Actions
    func on(peer: HMSSDK.HMSPeer, update: HMSSDK.HMSPeerUpdate)

  
    /// This is called when there are updates on an existing track
    /// or a new track got added/existing track is removed
    /// This callback can be used to render the video on screen whenever a track gets added
    /// - Parameters:
    ///   - track: the track which was added, removed or updated
    ///   - update: the triggered update type
    ///   - peer: the peer for which track was added, removed or updated
    func on(track: HMSTrack, update: HMSSDK.HMSTrackUpdate, for peer: HMSSDK.HMSPeer)

  
    /// This will be called when there is an error in the system
    /// and SDK has already retried to fix the error
    /// - Parameter error: the error that occured
    func on(error: HMSError)

  
    /// This is called when there is a new broadcast message from any other peer in the room
    /// This can be used to implement chat is the room
    /// - Parameter message: the received broadcast message
    func on(message: HMSSDK.HMSMessage)

  
    func on(updated speakers: [HMSSDK.HMSSpeaker])

    @objc func onReconnecting()

    @objc func onReconnected()
}
```
  
## 🤔 How to listen to Track, Peer and Room updates? 

  The HMS SDK sends updates to the application about any change in HMSPeer , HMSTrack or HMSRoom via the callbacks in HMSUpdateListener.
  Application need to listen to the corresponding updates in onPeerUpdate , onTrackUpdate or onRoomUpdate

  The following are the different types of updates that are emitted by the SDK - 
```
  HMSPeerUpdate
    case PEER_JOINED A new peer joins the room
    case PEER_LEFT - An existing peer leaves the room
    case BECAME_DOMINANT_SPEAKER - A peer becomes a dominant speaker
    case NO_DOMINANT_SPEAKER - There is silence in the room (No speaker is detected)
    
  HMSTrackUpdate
    case TRACK_ADDED - A new track is added by a remote peer
    case TRACK_REMOVED - An existing track is removed from a remote peer
    case TRACK_MUTED - An existing track of a remote peer is muted
    case TRACK_UNMUTED - An existing track of a remote peer is unmuted
    case TRACK_DESCRIPTION_CHANGED - The optional description of a track of a remote peer is changed
 ```
  
## 🛤 How to know the type and source of Track?

  HMSTrack contain a field called source which denotes the source of the Track. 
  Source can have the following values - regular (normal), screen (for screenshare)and plugin (for plugins)

  To know the type of track, check the value of type which would be one of the enum values - AUDIO or VIDEO
  
## 🤝 Provide joining configuration

To join a room created by following the steps described in the above section, clients need to create a `HMSConfig` instance and use that instance to call `join` method of `HMSSDK`

```
  // Create a new HMSConfig
  let config = HMSConfig(userName: user, // name of the user
                           userID: UUID().uuidString, // some unique identifier
                           roomID: room, // unique ID of the room which user wants to join
                        authToken: token) // authorisation token of the user
```

## 🙏 Join a room

Use the HMSConfig and HMSUpdateListener instances to call the join method on the instance of HMSSDK created above.
Once Join succeeds, all the callbacks keep coming on every change in the room and the app can react accordingly

```
  // Basic Usage
  hms = HMSSDK.build() // ensure to keep an instance of HMSSDK alive in the class as an instance property
  let config = HMSConfig(userID: "userID", roomID: "roomID", authToken: "authToken") 
  hms?.join(config: config, delegate: self)
  
  
  // Advanced Usage
  hms = HMSSDK.build { (hms) in
            hms.logLevel = .verbose
            hms.analyticsLevel = .verbose
            let videoSettings = HMSVideoTrackSettings(maxBitrate: 512,
                                                      maxFrameRate: 25,
                                                      cameraFacing: .front,
                                                      trackDescription: "Just a normal video track")
            let audioSettings = HMSAudioTrackSettings(maxBitrate: 32, trackDescription: "Just a normal audio track")
            hms.trackSettings = HMSTrackSettings(videoSettings: videoSettings, audioSettings: audioSettings)
            hms.logger = self
        }
  
  let config = HMSConfig(userName: "userName",
                           userID: "userID",
                           roomID: "roomID",
                        authToken: "authToken",
              shouldSkipPIIEvents: true,
                         metaData: "someMetaData",
                         endpoint: "wss://myWebSocketEndpoint/ws")

  hms?.join(config: config, delegate: self)

```

## 👋 Leave Room

Call the leave method on the HMSSDK instance

```
hms?.leave() // to leave a room
```

## 👌 Get Peers/tracks data

`HMSSDK` has other methods which the client app can use to get more info about the `Room`, `Peer` and `Tracks`

```  
  /// Returns the local peer, which contains the local tracks
  var localPeer: HMSLocalPeer? { get }
  
  
  /// Returns all remote peers in the room
  var remotePeers: [HMSRemotePeer]? { get }
  
  
  /// Returns the room which was joined
  var room: HMSRoom? { get }
```
  
## 🙊 Mute/Unmute Local Audio
Use the `HMSLocalAudioTrack` and `HMSLocalVideoTrack` to mute/unmute tracks
  
```
class HMSLocalAudioTrack : HMSAudioTrack {

  var settings: HMSAudioTrackSettings
  
  func setMute(_ mute: Bool)
}
```

## 🙈 Mute/Unmute Local Video  
  
```  
  class HMSLocalVideoTrack : HMSVideoTrack {

    var settings: HMSVideoTrackSettings
    
    func setMute(_ mute: Bool)

    func startCapturing()

    func stopCapturing()

    func switchCamera()
}
```
  
## 🛤 HMSTracks Explained
  
`HMSTrack` is the super-class of all the tracks that are used inside `HMSSDK`. Its hierarchy looks like this -
  
```
  HMSTrack
      - AudioTrack
          - LocalAudioTrack
          - RemoteAudioTrack
      - VideoTrack
          - LocalVideoTrack
          - RemoteVideoTrack
```
  
## 🎞 Display a Track
  To display a video track, first get the `HMSVideoTrack` & pass it on to `HMSVideoView` using `setVideoTrack` function. Ensure to attach the `HMSVideoView` to your UI hierarchy.

  ```
  // The following code is a sample.

  // Get the video track to be displayed
  let track = peer.videoTrack  

  // Create a view for rendering video track and add to the UI hierarchy

  let videoView = HMSVideoView()
  videoView.setVideoTrack(track)
  view.addSubview(videoView)

  ```

  
  Checkout the sample implementation in the [Example app folder](https://github.com/100mslive/100ms-ios-sdk/tree/main/Example).
