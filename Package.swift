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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.4.1/HMSSDK.xcframework.zip",
            checksum: "1d9783c4d683b4e7bcb0d091fea1e676b04d04f3db182edb84906ee229114251"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.4898/WebRTC.xcframework.zip",
            checksum: "cf744aa15fa77b9b02151d1ed34c739f5bd72574664373da484d42c338f94d2e"
        )
    ]
)
