// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "HMSSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "HMSSDK",
            targets: ["HMSSDK", "WebRTC", "dependencies"])
    ],
    dependencies: [
        .package(name: "HMSAnalyticsSDK", url: "https://github.com/100mslive/100ms-ios-analytics-sdk", from: "0.0.2"),
    ],
    targets: [
        .binaryTarget(
            name: "HMSSDK",
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.7.1/HMSSDK.xcframework.zip",
            checksum: "434cbf07c6340ece46fd5b49d6e3b16b21060b72b60de61b613068e4d2c5d0c6"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.5115/WebRTC.xcframework.zip",
            checksum: "4596d1383d45d206cdced61237f6fc5cef4793f749f19e1fe7e4af64d2db42c2"
        ),
        .target(name: "dependencies", dependencies: ["HMSAnalyticsSDK"], path: "dependencies")
    ]
)
