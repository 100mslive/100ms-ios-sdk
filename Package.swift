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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/1.16.1/HMSSDK.xcframework.zip",
            checksum: "a7d4439d549715c7d8d4badd4b502e21c195257d4dc907681724cbe6065ad797"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.6171/WebRTC.xcframework.zip",
            checksum: "29bc00b163c3de382f53fdfe6f4ceacb1b67f45072231244e7b0dc0bcb413317"
        ),
        .target(name: "HMSSDKDependencies", dependencies: ["HMSAnalyticsSDK"], path: "dependencies")
    ]
)
