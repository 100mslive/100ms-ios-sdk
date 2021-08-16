<p align="center" >
  <a href="https://100ms.live/">
  <img src="https://github.com/100mslive/100ms-ios-sdk/blob/main/100ms-logo.png" title="100ms logo" float=left>
</p>

![Cocoapods](https://img.shields.io/cocoapods/v/HMSSDK)
![iOS](https://img.shields.io/badge/iOS-10.0%2B-yellow)
[![License](https://img.shields.io/cocoapods/l/HMSSDK.svg?style=flat)](http://cocoapods.org/pods/HMSSDK)
[![Documentation](https://img.shields.io/badge/Read-Documentation-blue)](https://docs.100ms.live/ios/v2/foundation/Basics)
[![Discord](https://img.shields.io/badge/Community-Join%20on%20Discord-blue)](https://discord.gg/F8cNgbjSaQ)
[![Slack](https://img.shields.io/badge/Community-Join%20on%20Slack-blue)](https://join.slack.com/t/100mslive/shared_invite/zt-llwdnz11-vkb2RzptwacwXHO7UeY0CQ)
[![Email](https://img.shields.io/badge/Contact-Know%20More-blue)](mailto:founders@100ms.live)

<img src="https://github.com/100mslive/100ms-ios-sdk/blob/updateReadMe/100ms.gif" width="64" height="64" />

# 🎉 100ms SDK ＆ Sample App 🚀

Here you will find everything you need to build experiences with video using 100ms iOS SDK. Dive into our SDKs, quick starts, add real-time video, voice, and screen sharing to your web and mobile applications.

👀 To see a Example App implementation of 100ms SDK, checkout the [ReadMe in Example folder](https://github.com/100mslive/100ms-ios-sdk/tree/main/Example).

📲 Download the 100ms fully featured Sample iOS app here: https://testflight.apple.com/join/dhUSE7N8
  
## ☝️ Pre-requisites
- Xcode 12 or higher
- Support for iOS 10 or higher

## 🚂 Setup Guide
  
  1. Sign up on https://dashboard.100ms.live/register & visit the Developer tab to access your credentials.
  
  2. Get familiarized with [Tokens & Security here](https://docs.100ms.live/ios/v2/foundation/Security-and-tokens)

  3. Complete the steps in [Auth Token Quick Start Guide](https://docs.100ms.live/ios/v2/guides/Token)
  
  4. Get the HMSSDK via [Cocoapods](https://cocoapods.org/). Add the `pod 'HMSSDK'` to your Podfile as follows:
  ```
  // Podfile
  
  platform :ios, '10.0'

  target 'MyAwesomeApp' do
    pod 'HMSSDK'
  end
  ```

  Follow the [iOS Quick Start Guide as mentioned here](https://docs.100ms.live/ios/v2/guides/Quickstart).
  
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
    func on(join room: HMSRoom)

  
    /// This is called when there is a change in any property of the Room
    /// - Parameters:
    ///   - room: the room which was joined
    ///   - update: the triggered update type. Should be used to perform different UI Actions
    func on(room: HMSRoom, update: HMSRoomUpdate)

  
    /// This will be called whenever there is an update on an existing peer
    /// or a new peer got added/existing peer is removed.
    /// This callback can be used to keep a track of all the peers in the room
    /// - Parameters:
    ///   - peer: the peer who joined/left or was updated
    ///   - update: the triggered update type. Should be used to perform different UI Actions
    func on(peer: HMSPeer, update: HMSPeerUpdate)

  
    /// This is called when there are updates on an existing track
    /// or a new track got added/existing track is removed
    /// This callback can be used to render the video on screen whenever a track gets added
    /// - Parameters:
    ///   - track: the track which was added, removed or updated
    ///   - update: the triggered update type
    ///   - peer: the peer for which track was added, removed or updated
    func on(track: HMSTrack, update: HMSTrackUpdate, for peer: HMSPeer)

  
    /// This will be called when there is an error in the system
    /// and SDK has already retried to fix the error
    /// - Parameter error: the error that occured
    func on(error: HMSError)

  
    /// This is called when there is a new broadcast message from any other peer in the room
    /// This can be used to implement chat is the room
    /// - Parameter message: the received broadcast message
    func on(message: HMSMessage)

  
    /// This is called every 1 second with list of active speakers
    ///
    /// ## A HMSSpeaker object contains -
    ///    - HMSPeer: the peer who is speaking
    ///    - trackID: the track identifier of HMSTrack which is emitting audio
    ///    - level: a number within range 1-100 indicating the audio volume
    ///
    /// A peer who is not present in the list indicates that the peer is not speaking
    ///
    /// This can be used to highlight currently speaking peers in the room
    /// - Parameter speakers: the list of speakers
    func on(updated speakers: [HMSSpeaker])

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

## 📨 Chat Messaging
You can send a chat or any other kind of message from local peer to all remote peers in the room.

To send a message first create an instance of `HMSMessage` object.

Add the information to be sent in the `message` property of `HMSMessage`.

Then use the `func send(message: HMSMessage)` function on instance of HMSSDK.

When you(the local peer) receives a message from others(any remote peer), `func on(message: HMSMessage)` function of `HMSUpdateListener` is invoked.
  
```
  // following is an example implementation of chat messaging

  // to send a broadcast message
  let broadcast = HMSMessage(sender: "peerID", // the peerID of local peer, can be empty
                             time: "\(Date())", // the timestamp when message is being sent, can be empty
                             type: "chat", // the type of message, you can set it to any arbitary string value & use it to filter on your Chat UI
                             message: "my message") // the message information to be sent in string

  hmsSDK.send(message: broadcast) // hmsSDK is an instance of `HMSSDK` object

  // receiving messages
  // the object conforming to `HMSUpdateListener` will be invoked with `on(message: HMSMessage)`, add your logic to update Chat UI within this listener
  func on(message: HMSMessage) {
      let messageReceived = message.message // extract message payload from `HMSMessage` object that is received
      // update your Chat UI with the messageReceived
  }
```

## 🤳 Preview

Preview screen is a frequently used UX element which allows users to check if their input devices are working properly and set the initial state (mute/unmute) of their audio and video tracks before joining. 100ms SDKs provide an easy-to-use API to back this feature. Additionally, the SDK will try to establish a connection to 100ms server to verify there are no network issues and that the auth credentials are valid so that if everything is in order the subsequent room join is instant.

To invoke this API call

```swift
hmsSDK.preview(config: config, delegate: previewDelegate)
```

You would need the same config object that you would pass to [join API](Join). The `previewDelegate` is an object conforming to `HMSPreviewListener` protocol that has two callbacks:

```swift
func onPreview(room: HMSRoom, localTracks: [HMSTrack])
```

Which is called when SDK has passed all its preflight checks and established the connection to 100ms server. This will pass an array of local tracks that you can display to the user (see [Render Video](Render-Video) and [Mute](Mute) sections for more details).

If however there was some error related to getting the input sources or some preflight check has failed 

```swift
func on(error: HMSError)
```

Delegate callback will be fired with the HMSError instance which you can use to find what went wrong.

## ⚙️ Change Role

Role is a powerful concept that takes a lot of complexity away in handling permissions and supporting features like breakout rooms. [Learn more about roles here.](../foundation/templates-and-roles)

Each `HMSPeer` instance has a `role` property which returns an `HMSRole` instance. You can use this property to do following:

1. Check what this role is allowed to publish. I.e can it send video (and at what resolution)? can it send audio? can it  share screen? Who can this role subscribe to? (I.e student can only see the teacher's video) This is can be discovered by checking `publishSettings` and `subscribeSettings` properties
2. Check what actions this role can perform. i.e can it change someone else's current role, end meeting, remove someone from the room. This is can be discovered by checking `permissions` property

In certain scenarios you may want to change someone's role. Imagine an audio room with 2 roles "speaker" and "listener". Only someone with a "speaker" role can publish audio to the room while "listener" can only subscribe. Now at some point "speaker" may decide to nominate some "listener" to become a "speaker". This is where the `changeRole` API comes in.

To invoke the api you will need 2 things. An instance of `HMSPeer` of the peer who's role you want to change and the `HMSRole` instance for the target role.  All the peers that are in the current room are accessible via `peers` property of `HMSRoom` instance that you can get via `room` property of `HMSSDK` instance after successful room join. A list of all available roles in the current room can be accessed via `roles` property of `HMSSDK` 

Once you have both you can invoke

```swift
 hmsSDK.changeRole(for: targetPeer, role: targetRole)
```

If the change role succeeds you will get a 

```swift
func on(peer: HMSPeer, update: HMSPeerUpdate)
```

delegate callback with the the same peer you passed as targetPeer and a `roleUpdated` update type.

`changeRole` has an optional `force` parameter which is `false` by default meaning that `changeRole` is basically a polite request: "Would you like to change you role from listener to speaker?" which can be ignored by the other party. The way it works is the other party will first receive a 

```swift
func on(roleChangeRequest: HMSRoleChangeRequest)
```

delegate callback. At which point app can choose to show a prompt to the user asking for permission. If the user accepts, app should call 

```swift
hmsSDK.accept(changeRole: roleChangeRequest)
```

which completes the `changeRole` loop. Both parties will receive a `roleUpdated` callback so that they both can do necessary UI updates. Now the user actually becomes a speaker and the audio publishing will start automatically. 

Now lets imagine the newly nominated speaker is not behaving nicely and we want to move him back to listener without a prompt. This is where the `force` parameter comes in. When it is set to `true` the other party will not receive a confirmation `roleChangeRequest` but instead will straight away receive a new set of updated permissions and stop publishing. `roleUpdated` callback will still be fired so that the app can update the user's UI state.
  

## ❌ Error Handling

When you make an API call to access an HMS SDK, the SDK may return error codes. ErrorCodes are returned when a problem that cannot be recovered without app intervention has occurred.

These are returned as `HMSError` in the `func on(error: HMSError)` callback of the `HMSUpdateListner`.

Following are the different error codes that are returned by the SDK . Before returning any error code, SDK retries the errors\(whichever is possible\).

| **Error Code** | **Cause of the error**                                 | **Action to be taken**                                                                                     |
| :------------- | :----------------------------------------------------- | :--------------------------------------------------------------------------------------------------------- |
| **1003**       | Websocket disconnected - Happens due to network issues | Mention user to check their network connection or try again after some time.                                |
| **2002**       | Invalid Endpoint URL                                   | Check the endpoint provided while calling `join` on `HMSSDK`.                                               |
| **2003**       | Endpoint is not reachable                              | Mention user to check their network connection or try again after some time.                                |
| **2004**       | Token is not in proper JWT format                      | The token passed while calling `join` is not in correct format. Retry getting a new token.                  |
| **3001**       | Cant Access Capture Device                             | Ask user to check permission granted to audio/video capture devices.                                        |
| **3002**       | Capture Device is not Available                        | Ask user to check if the audio/video capture device is connected or not.                                    |
| **3003**       | Capture device is in use by some other application     | Show notification to user mentioning that the capturing device is used by some other application currently. |
| **3008**       | Browser has throw an autoplay exception                | Show notification to user mentioning that the browser blocked autoplay |
| **4001**       | WebRTC error                                           | Some webRTC error has occured. Need more logs to debug.                                                     |
| **4002**       | WebRTC error                                           | Some webRTC error has occured. Need more logs to debug.                                                     |
| **4003**       | WebRTC error                                           | Some webRTC error has occured. Need more logs to debug.                                                     |
| **4004**       | WebRTC error                                           | Some webRTC error has occured. Need more logs to debug.                                                     |
| **4005**       | ICE Connection Failed due to network issue             | Mention user to check their network connection or try again after some time.                                |
| **5001**       | Trying to join a room which is already joined          | Trying to join an already joined room.                                                                     |
| **6002**       | webRTC Error: Error while renegotiating                | Please try again.                                                                                           |
| **40101**      | Token Error: Invalid Access Key                        | Access Key provided in the token is wrong.                                                                  |
| **40102**      | Token Error: Invalid Room Id                           | RoomID provided in the token is wrong.                                                                      |
| **40103**      | Token Error: Invalid Auth Id                           | AuthID provided in the token is wrong.                                                                      |
| **40104**      | Token Error: Invalid App Id                            | App ID provided in the token is wrong.                                                                      |
| **40105**      | Token Error: Invalid Customer Id                       | Customer Id provided in the token is wrong.                                                                 |
| **40107**      | Token Error: Invalid User Id                           | User ID provided in the token is wrong.                                                                     |
| **40108**      | Token Error: Invalid Role                              | The role provided in the token is wrong.                                                                    |
| **40109**      | Token Error: Bad JWT Token                             | Bad JWT Token.                                                                                              |
| **40100**      | Generic Error                                          | Need to debug further with logs.                                                                            |
| **40001**      | Invalid Room                                           | Room ID provided while fetching the token is an invalid room.                                               |
| **40002**      | Room Mismatched with Token                               | Room ID provided while fetching the token does not match.                                                   |
| **40004**      | Peer already joined                                    | Peer who is trying to join has already joined the room.                                                     |
| **41001**      | Peer is gone                                           | The peer is no more present in the room.                                                                    |

👀 Checkout the sample implementation in the [Example app folder](https://github.com/100mslive/100ms-ios-sdk/tree/main/Example).

📲 Download the 100ms fully featured Sample iOS app here: https://testflight.apple.com/join/dhUSE7N8
