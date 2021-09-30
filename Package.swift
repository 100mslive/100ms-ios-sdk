// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "HMSSDK",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "HMSSDK",
            targets: ["HMSSDK", "WebRTC"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "HMSSDK",
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.1.2/HMSSDK.xcframework.zip",
            checksum: "66d46ce04dfec6d0d6623e58776abda8c13f96430ef20389ed12bcba44dd992b"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.4515/WebRTC.xcframework.zip",
            checksum: "aac8b5307c5b40fbfab958eea617ce61da6a1097ddd317d0eae55a00b8ce813f"
        )
    ]
)
