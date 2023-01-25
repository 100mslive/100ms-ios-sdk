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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.6.4/HMSSDK.xcframework.zip",
            checksum: "725d8f0709e421911d3809c20b30061d55326024897db0a161b02d980f84c1c5"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.5113/WebRTC.xcframework.zip",
            checksum: "ab9c595207d29de457c22b2ec3fa7e632ef57daf9fbc90ed93eaf99a64b1893f"
        )
    ]
)
