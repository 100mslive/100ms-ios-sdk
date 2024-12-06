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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/1.16.7/HMSSDK.xcframework.zip",
            checksum: "67228edf837f6a2d7818e4b3ae1d2245ad625392f765f72de6c8024eceec5033"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.6172/WebRTC.xcframework.zip",
            checksum: "4b4e0d6fe7934deb544ec0c812bf00665c8b57b210573ad58be9e7d7c4c590f6"
        ),
        .target(name: "HMSSDKDependencies", dependencies: ["HMSAnalyticsSDK"], path: "dependencies")
    ]
)
