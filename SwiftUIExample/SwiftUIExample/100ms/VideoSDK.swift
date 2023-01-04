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
    @Published var peers = [HMSPeer]()
    @Published var isJoined = false
    
    func joinRoom() {
        let config = HMSConfig(userName:"John Doe", authToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2Nlc3Nfa2V5IjoiNjFmMTc3NDE0ZjZiMDIxOGYyM2I3Yzg4Iiwicm9vbV9pZCI6IjYxZjE3N2Q2ZDg1YmYwNWVlNGUxN2U0NiIsInVzZXJfaWQiOiJhZ2hoeWNxciIsInJvbGUiOiJzdGFnZSIsImp0aSI6IjA1NTM4YjZjLTUxZDEtNGE0Ni1hYmM5LThiMjljOTQyZTBmMiIsInR5cGUiOiJhcHAiLCJ2ZXJzaW9uIjoyLCJleHAiOjE2NzI4MzU4OTd9.bxPM6LTuV1_r4NsnjRRMRcmdN_ePqFnbmfLzthcIqHU")
        hmsSDK.join(config: config, delegate: self)
    }
}

extension VideoSDK: HMSUpdateListener {
    func on(join room: HMSRoom) {
        isJoined = true
        if let peer = hmsSDK.localPeer {
            peers.append(peer)
        }
    }

    func on(room: HMSRoom, update: HMSRoomUpdate) {

    }

    func on(peer: HMSPeer, update: HMSPeerUpdate) {
        switch update {
        case .peerJoined:
            peers.append(peer)
        case .peerLeft:
            peers.removeAll { $0 == peer }
        default:
            break
        }
    }

    func on(track: HMSTrack, update: HMSTrackUpdate, for peer: HMSPeer) {
//        switch update {
//        case .trackAdded:
//            if let videoTrack = track as? HMSVideoTrack {
//                tracks.append(videoTrack)
//            }
//        case .trackRemoved:
//            if let videoTrack = track as? HMSVideoTrack {
//                tracks.removeAll { $0 == videoTrack }
//            }
//        default:
//            break
//        }
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
