//
//  VideoSDK.swift
//  SwiftUIExample
//
//  Created by Pawan Dixit on 16/12/2022.
//

import Foundation
import HMSSDK

class VideoSDK: ObservableObject {
    
    static let shared = VideoSDK()
    
    let hmsSDK = HMSSDK.build()
    @Published var peers = [HMSPeer]()
    @Published var peerSet = Set<HMSPeerModel>()
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
        
        guard let _ = (peerSet.first{$0.peer == peer}) else { return }
        
        switch update {
        case .trackAdded:
            peerSet = Set(peerSet.map { peerModel in
                if peerModel.peer == peer {
                    var peerModelCopy = peerModel
                    peerModelCopy.tracks.append(HMSTrackModel(track: track, isMuted: track.isMute()))
                    return peerModelCopy
                }
                else {
                    return peerModel
                }
            })
            
        case .trackRemoved:
            peerSet = Set(peerSet.map { peerModel in
                if peerModel.peer == peer {
                    var peerModelCopy = peerModel
                    peerModelCopy.tracks.removeAll{$0.track == track}
                    return peerModelCopy
                }
                else {
                    return peerModel
                }
            })
        case .trackMuted:
            
            peerSet = Set(peerSet.map { peerModel in
                if peerModel.peer == peer {
                    var peerModelCopy = peerModel
                    peerModelCopy.tracks = peerModel.tracks.map {
                        if $0.track == track {
                            var copy = $0
                            copy.isMuted = true
                            return copy
                        }
                        else {
                            return $0
                        }
                    }
                    
                    return peerModelCopy
                }
                else {
                    return peerModel
                }
            })
            
            
        case.trackUnmuted:
            
            peerSet = Set(peerSet.map { peerModel in
                if peerModel.peer == peer {
                    var peerModelCopy = peerModel
                    peerModelCopy.tracks = peerModel.tracks.map {
                        if $0.track == track {
                            var copy = $0
                            copy.isMuted = false
                            return copy
                        }
                        else {
                            return $0
                        }
                    }
                    
                    return peerModelCopy
                }
                else {
                    return peerModel
                }
            })
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
