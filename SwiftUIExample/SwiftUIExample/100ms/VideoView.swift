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
    
    let peer: HMSPeer
    
    var audioTrack: HMSAudioTrack? {
        peer.audioTrack
    }
    
    var localAudioTrack: HMSLocalAudioTrack? {
        peer.audioTrack as? HMSLocalAudioTrack
    }
    
    var videoTrack: HMSVideoTrack? {
        peer.videoTrack
    }
    
    var isLocal: Bool {
        peer.isLocal
    }
    
    var body: some View {
        ZStack {

            if let videoTrack = videoTrack {
                VideoView(track: videoTrack)
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
    }
}
