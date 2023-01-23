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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.6.2/HMSSDK.xcframework.zip",
            checksum: "98122ceb8b911d38b2e85f9642f0e4c7182a720722b4f5b3da3ec1de905cef12"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.5113/WebRTC.xcframework.zip",
            checksum: "ab9c595207d29de457c22b2ec3fa7e632ef57daf9fbc90ed93eaf99a64b1893f"
        )
    ]
)
