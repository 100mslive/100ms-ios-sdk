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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.3.1/HMSSDK.xcframework.zip",
            checksum: "0f2ed3270e73c5b191f613a777ed81cc15ead24baa19ff3265df8be6c3104e37"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.4897/WebRTC.xcframework.zip",
            checksum: "86d2ee4ce965cd2d12920da9bfc395a51a69e7db5bf2c327a72e1e69cc2c0dd4"
        )
    ]
)
