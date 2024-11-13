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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/1.16.6/HMSSDK.xcframework.zip",
            checksum: "1f47bd387b78e52a5ed752fccfb679590104b683eb8105094edf0c2d49b5324a"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.6172/WebRTC.xcframework.zip",
            checksum: "4b4e0d6fe7934deb544ec0c812bf00665c8b57b210573ad58be9e7d7c4c590f6"
        ),
        .target(name: "HMSSDKDependencies", dependencies: ["HMSAnalyticsSDK"], path: "dependencies")
    ]
)
