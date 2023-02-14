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
            checksum: "bc32b869377cbcdb5de83624de034150f18eff83be2fe2d55fa5cd6d83b3d186"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.5114/WebRTC.xcframework.zip",
            checksum: "65cf7d90fdf8e28081d5eeaee75a6fea68bc5a675cf3c272a99f26c4798dafce"
        )
    ]
)
