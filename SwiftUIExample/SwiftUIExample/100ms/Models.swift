//
//  Models.swift
//  SwiftUIExample
//
//  Created by Pawan Dixit on 04/01/2023.
//

import HMSSDK

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
