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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.2.15/HMSSDK.xcframework.zip",
            checksum: "a1fa0a124a6f1d3053537c376de8376e09d7bc3bb36a1728ea23b4685c32597d"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.4518/WebRTC.xcframework.zip",
            checksum: "2700a84705e2b40db467eae3ae7a40b86663e11f766b71c6b170a12527c33e11"
        )
    ]
)
