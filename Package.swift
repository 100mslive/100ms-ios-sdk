// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "HMSSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "HMSSDK",
            targets: ["HMSSDK", "WebRTC"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "HMSSDK",
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.6.5/HMSSDK.xcframework.zip",
            checksum: "6d01f392514107be9122e0781398e42b9b38df1a04945bd64bab9e56339a8ed4"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.5115/WebRTC.xcframework.zip",
            checksum: "4596d1383d45d206cdced61237f6fc5cef4793f749f19e1fe7e4af64d2db42c2"
        )
    ]
)
