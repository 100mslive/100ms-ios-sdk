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
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.6173/HMSWebRTC.xcframework.zip",
            checksum: "629db2db22918b716175886454aaa3c0c1f03b0761578ba89cab257d4100e278"
        ),
        .target(name: "HMSSDKDependencies", dependencies: ["HMSAnalyticsSDK"], path: "dependencies")
    ]
)
