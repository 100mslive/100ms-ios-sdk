# Example App

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
4. In the Login Screen of the app, for the first you'll be prompted for permission to access Camera & Microphone.
