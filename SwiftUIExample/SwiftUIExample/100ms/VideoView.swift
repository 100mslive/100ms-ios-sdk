//
//  HMSViewRepresentable.swift
//  SwiftUIExample
//
//  Created by Pawan Dixit on 16/12/2022.
//

import SwiftUI
import HMSSDK

struct VideoView: UIViewRepresentable {
    var track: HMSVideoTrack

    func makeUIView(context: Context) -> HMSVideoView {
        
        let videoView = HMSVideoView()
        videoView.setVideoTrack(track)
        videoView.videoContentMode = .scaleAspectFill
        return videoView
    }
    
    func updateUIView(_ videoView: HMSVideoView, context: Context) {}
}


@available(iOS 13.0.0, *)
struct HMSPeerTile: View {
    
    @ObservedObject var model = VideoSDK.shared
    
    let peer: HMSPeer
    
    var peerModel: HMSPeerModel? {
        model.peerSet.first{$0.peer == peer}
    }
    
    init(peer: HMSPeer) {
        self.peer = peer
    }
    
    var audioTrack: HMSAudioTrack? {
        peer.audioTrack
    }
    
    var localAudioTrack: HMSLocalAudioTrack? {
        guard let track = peer.audioTrack as? HMSLocalAudioTrack else { return nil }
        return (peerModel?.tracks.first{$0.track.trackId == track.trackId})?.track as? HMSLocalAudioTrack
    }
    
    var videoTrackModel: HMSTrackModel? {
        return (peerModel?.tracks.first{$0.track.trackId == peer.videoTrack?.trackId})
    }
    
    var isLocal: Bool {
        peer.isLocal
    }
    
    var body: some View {
        ZStack {

            if let videoTrackModel = videoTrackModel, !videoTrackModel.isMuted {
                VideoView(track: videoTrackModel.track as! HMSVideoTrack)
                    .edgesIgnoringSafeArea(.all)
            }
            else {
                Image(systemName: "person")
            }
            
            if let localAudioTrack = localAudioTrack {
                VStack {
                    Image(systemName: "mic")
                        .onTapGesture {
                            localAudioTrack.setMute(!localAudioTrack.isMute())
                        }
                    Spacer(minLength: 0)
                }
            }
        }
        .onAppear() {
            let tracks = [peer.videoTrack, peer.audioTrack].compactMap{$0}
            model.peerSet.insert(HMSPeerModel(peer: peer, tracks: tracks))
        }
        .onDisappear() {
            if let peerToRemove = Array(model.peerSet).first(where: {$0.peer == peer}) {
                model.peerSet.remove(peerToRemove)
            }
            else {
                assertionFailure()
            }
        }
    }
}
