# Example App

This guide walks you through the Example app implementation showcasing how 100ms SDK can be utilized to build delightful apps.🤩

You can download the [Sample App via TestFlight here](https://testflight.apple.com/join/dhUSE7N8).

For the SDK integration guide, checkout the [ReadMe here](https://github.com/100mslive/100ms-ios-sdk/).

## ☝️ Pre-requistes
- Xcode 12 or higher
- Support for iOS 10 or higher
- Complete the 5 steps of [Setup Process as listed here](https://github.com/100mslive/100ms-ios-sdk#-setup-guide) to get Access Keys & Tokens 

## 🏎 Run the application
1. Put in your Token Endpoint at Code completion mark in `Constants.swift` file Line 15. 

    The `Constants` file is located at path `Example/HMSSDKExample/SupportingFiles/Constants.swift` 

    Make sure it ends with a backslash (/)

    For example:
    ```
    static let tokenEndpoint = "https://prod-in.100ms.live/hmsapi/<your-subdomain>/"  # ✅ Valid
    static let tokenEndpoint = "https://prod-in.100ms.live/hmsapi/<your-subdomain>"   # ❌ invalid
    ```
2. Ensure that [Cocoapods](https://cocoapods.org/) is installed on your Mac.
3. In the Example folder, run `pod install` to install dependencies of the Example app.
4. Open the `HMSSDKExample.xcworkspace` file & Build & Run the `HMSSDKExample` target on Simulator.
5. To run the Example app on your device, you'll need to add your Apple Developer Team in Signing & Capabilites tab of Xcode.

## 🚶‍♀️ App User Walkthrough

#### Login Screen
- For the first run of the app, you'll be prompted for permission to access Camera & Microphone.

- In the Login Screen of the app, Enter your Meeting RoomID & click on Join Meeting.

- You'll be prompted to Enter your Name. Type in the name you want to use in the Meeting Room. 


https://user-images.githubusercontent.com/8512357/124134349-60e25400-daa0-11eb-95bb-fe8e45b613fa.mov


#### Meeting Screen
On clicking Join Meeting, you'll be taken to the Meeting Screen & will see a spinner until you have joined the Room. On the Meeting screen, you have multiple controls for - 
- Showing Meeting Room Name
- Tap on Meeting Room Name to view Peers List
- Mute Audio of all Peers
- Switch Camera (Front/Back)
- Change Meeting Layout
- Muting/Unmuting Camera
- Muting/Unmuting Microphone
- Show Chat Screen
- Leave Meeting 

<img width="412" alt="Meeting Screen" src="https://user-images.githubusercontent.com/8512357/124134849-e1a15000-daa0-11eb-89bd-22c0bc24ba1e.png">


The Sample app has various View Modes which change the layout of the Meeting. Clicking the Change Meeting Layout button on the top right of the screen shows the following Mode options - 
1. Audio Only Mode
2. Show Active Speakers
3. Video Only Mode
4. All Pinned Mode
5. Spotlight Mode
6. Hero Mode
7. Default Mode

https://user-images.githubusercontent.com/8512357/124134456-7a839b80-daa0-11eb-8220-7c37c745c58e.mov

The files of importance are listed below -
- [HMSSDKInteractor](https://github.com/100mslive/100ms-ios-sdk/blob/main/Example/HMSSDKExample/Meeting/HMSSDKInteractor.swift): Interacts with HMSSDK & conforms to the HMSUpdateListener protocol to listen for updates like Peer Join/Leave, Track Mute/Unmute, etc coming in from the SDK.
