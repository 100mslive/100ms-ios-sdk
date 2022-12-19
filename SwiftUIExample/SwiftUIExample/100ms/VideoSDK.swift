//
//  VideoSDK.swift
//  SwiftUIExample
//
//  Created by Pawan Dixit on 16/12/2022.
//

import Foundation
import HMSSDK

class VideoSDK: ObservableObject {
    
    let hmsSDK = HMSSDK.build()
    @Published var tracks = [HMSVideoTrack]()
    @Published var isJoined = false
    
    func joinRoom() {
        let config = HMSConfig(userName:"John Doe", authToken: "insert token here")
        hmsSDK.join(config: config, delegate: self)
    }
}

extension VideoSDK: HMSUpdateListener {
    func on(join room: HMSRoom) {
        isJoined = true
    }

    func on(room: HMSRoom, update: HMSRoomUpdate) {

    }

    func on(peer: HMSPeer, update: HMSPeerUpdate) {
        switch update {
        case .peerLeft:
            if let videoTrack = peer.videoTrack {
                tracks.removeAll { $0 == videoTrack }
            }
        default:
            break
        }
    }

    func on(track: HMSTrack, update: HMSTrackUpdate, for peer: HMSPeer) {
        switch update {
        case .trackAdded:
            if let videoTrack = track as? HMSVideoTrack {
                tracks.append(videoTrack)
            }
        case .trackRemoved:
            if let videoTrack = track as? HMSVideoTrack {
                tracks.removeAll { $0 == videoTrack }
            }
        default:
            break
        }
    }

    func on(error: Error) {
        print(error.localizedDescription)
    }

    func on(message: HMSMessage) {

    }

    func on(updated speakers: [HMSSpeaker]) {

    }

    func onReconnecting() {

    }

    func onReconnected() {

    }
}
