// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "HMSSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "HMSSDK",
            targets: ["HMSSDK", "WebRTC", "HMSSDKDependencies"])
    ],
    dependencies: [
        .package(name: "HMSAnalyticsSDK", url: "https://github.com/100mslive/100ms-ios-analytics-sdk", from: "0.0.2"),
    ],
    targets: [
        .binaryTarget(
            name: "HMSSDK",
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/1.11.0/HMSSDK.xcframework.zip",
            checksum: "9942a1c85d5d2d05307693049b7769137cd03945b2a046577e07d508705a84e8"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.6169/WebRTC.xcframework.zip",
            checksum: "d07b1c68defc145067a4e684bc2a88911803871eeec702b2cb00cb18146898f5"
        ),
        .target(name: "HMSSDKDependencies", dependencies: ["HMSAnalyticsSDK"], path: "dependencies")
    ]
)
