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
