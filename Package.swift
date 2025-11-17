// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "HMSSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "HMSSDK",
            targets: ["HMSSDK", "HMSWebRTC", "HMSSDKDependencies"])
    ],
    dependencies: [
        .package(name: "HMSAnalyticsSDK", url: "https://github.com/100mslive/100ms-ios-analytics-sdk", from: "0.0.2"),
    ],
    targets: [
        .binaryTarget(
            name: "HMSSDK",
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/1.17.1/HMSSDK.xcframework.zip",
            checksum: "3f24797f5e49e53d4cbe807e4a59ebcbaf2676a701e99f0cc11ca67e2c4edfae"
        ),
        .binaryTarget(
            name: "HMSWebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.6174/HMSWebRTC.xcframework.zip",
            checksum: "0df3b959a283b44e92cbb5a90d1734f5b8f9768ae972228a727067e0df58d5d1"
        ),
        .target(name: "HMSSDKDependencies", dependencies: ["HMSAnalyticsSDK"], path: "dependencies")
    ]
)
