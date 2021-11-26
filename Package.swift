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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.2.2/HMSSDK.xcframework.zip",
            checksum: "c2ad22fe09496673dbf41e2291d931d56b23bf8741aca20331eb61487b8f8396"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.4515/WebRTC.xcframework.zip",
            checksum: "aac8b5307c5b40fbfab958eea617ce61da6a1097ddd317d0eae55a00b8ce813f"
        )
    ]
)
