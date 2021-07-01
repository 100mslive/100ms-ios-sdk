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

https://user-images.githubusercontent.com/8512357/124128909-dd723400-da9a-11eb-9ca9-2cc8a547ebce.mov



#### Meeting Screen
In the Meeting screen of the Example app you have multiple controls for - 
- Show Meeting Room Name
- Tap on Meeting Room Name to view Participants List
- Switch Camera (Front/Back)
- Meeting Settings
- Muting/Unmuting Camera
- Muting/Unmuting Microphone
- Show Chat Screen
- Leave Meeting 

https://user-images.githubusercontent.com/8512357/124132106-17910500-da9e-11eb-8cf0-998ed6a69384.mov
