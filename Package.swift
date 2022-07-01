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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.3.2/HMSSDK.xcframework.zip",
            checksum: "366b7e3b3ee081620fd094f7e2f2077734ffb04843160b3b1ee4b820b6c24c3d"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.4897/WebRTC.xcframework.zip",
            checksum: "86d2ee4ce965cd2d12920da9bfc395a51a69e7db5bf2c327a72e1e69cc2c0dd4"
        )
    ]
)
