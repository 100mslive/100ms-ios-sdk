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
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.2.6/HMSSDK.xcframework.zip",
            checksum: "d0a1da69e28ebc7c76c67cc830a36e333a0b91f986396b65d2c615a3f8630b20"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.4518/WebRTC.xcframework.zip",
            checksum: "2700a84705e2b40db467eae3ae7a40b86663e11f766b71c6b170a12527c33e11"
        )
    ]
)
