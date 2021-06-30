# Example App

You can download the [Sample App via TestFlight here](https://testflight.apple.com/join/dhUSE7N8).

## ☝️ Pre-requistes
- Xcode 12 or higher
- Support for iOS 10 or higher
- Complete the 5 steps of [Setup Process as listed here](https://github.com/100mslive/100ms-ios-sdk#-setup-guide) to get Access Keys & Tokens 

## 🏎 Run the application
1. Put in your Token Endpoint at Code completion mark in `Constants.swift` Line 15. Make sure it ends with a backslash (/)

    For example:
    ```
    static let tokenEndpoint = "https://prod-in.100ms.live/hmsapi/<your-subdomain>/"  # ✅ Valid
    static let tokenEndpoint = "https://prod-in.100ms.live/hmsapi/<your-subdomain>"   # ❌ invalid
    ```
