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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.5.4/HMSSDK.xcframework.zip",
            checksum: "eed1d5e4c48d876ead8884d26d457552ad7d54533bb64d06d5cfc94074946514"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.5113/WebRTC.xcframework.zip",
            checksum: "ab9c595207d29de457c22b2ec3fa7e632ef57daf9fbc90ed93eaf99a64b1893f"
        )
    ]
)
