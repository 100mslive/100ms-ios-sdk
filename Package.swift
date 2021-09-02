// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "HMSSDK",
    platforms: [.iOS(.v10)],    
    products: [
        .library(
            name: "HMSSDK",
            targets: ["HMSSDK", "WebRTC"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "HMSSDK", 
            url: "https://github.com/100mslive/100ms-ios-sdk/releases/download/0.0.12/HMSSDK.xcframework.zip",
            checksum: "0cbfa93e9bbf2f1a47bb457fb718bd47d964f3c0b41047fd93c06709823e7c0c"
        ),
        .binaryTarget(
            name: "WebRTC", 
            url: "https://github.com/100mslive/webrtc-ios/releases/download/1.0.4515/WebRTC.xcframework.zip",
            checksum: "aac8b5307c5b40fbfab958eea617ce61da6a1097ddd317d0eae55a00b8ce813f"
        )                
    ]
)
