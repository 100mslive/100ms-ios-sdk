//
//  Models.swift
//  SwiftUIExample
//
//  Created by Pawan Dixit on 04/01/2023.
//

import HMSSDK

class HMSPeerTileModel: ObservableObject, HMSUpdateListener {
    
    static let shared = HMSPeerTileModel()
    
    @Published var peerSet = Set<HMSPeerModel>()
    
    func on(join room: HMSRoom) {
    }

    func on(room: HMSRoom, update: HMSRoomUpdate) {

    }

    func on(peer: HMSPeer, update: HMSPeerUpdate) {
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

struct HMSPeerModel: Equatable, Hashable {
    
    var peer: HMSPeer
    
    var tracks = [HMSTrackModel]()
    
    init(peer: HMSPeer, tracks: [HMSTrack]) {
        self.peer = peer
        self.tracks.append(contentsOf: tracks.map{HMSTrackModel(track: $0, isMuted: $0.isMute())})
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(peer)
    }
    
    static func == (lhs: HMSPeerModel, rhs: HMSPeerModel) -> Bool {
        lhs.peer == rhs.peer
    }
}

struct HMSTrackModel {
    let track: HMSTrack
    var isMuted: Bool
    
    init(track: HMSTrack, isMuted: Bool) {
        self.track = track
        self.isMuted = isMuted
    }
}
