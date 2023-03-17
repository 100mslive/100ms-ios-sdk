//
//  HLSMetadataView.swift
//  HMSSDKExample
//
//  Created by Pawan Dixit on 31/01/2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI
import HMSHLSPlayerSDK

class HLSPlayerOverlayModel: ObservableObject {
    @Published var cues = [HMSHLSCue]()
    @Published var state : HMSHLSPlaybackState?
}

struct HLSPlayerOverlayView: View {
    
    weak var player: HMSHLSPlayer?
    @ObservedObject var model: HLSPlayerOverlayModel
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                if let state = model.state {
                    switch state {
                    case .playing:
                        Text("Playing")
                    case .stopped:
                        Text("Stopped")
                    case .paused:
                        Text("Paused")
                    case .buffering:
                        Text("Buffering")
                    case .failed:
                        Text("Failed")
                    case .unknown:
                        Text("Unknown")
                    @unknown default:
                        Text("Unknown")
                    }
                    
                    Spacer(minLength: 0)
                    
                    HStack(spacing: 10) {
                        
                        Image(systemName: "gobackward.5")
                            .foregroundColor(.white)
                            .padding(5)
                            .padding(.horizontal, 5)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .onTapGesture {
                                player?.seekBackward(seconds: 5)
                                let impactMed = UIImpactFeedbackGenerator(style: .light)
                                impactMed.impactOccurred()
                            }
                        
                        Image(systemName: "goforward.5")
                            .foregroundColor(.white)
                            .padding(5)
                            .padding(.horizontal, 5)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .onTapGesture {
                                player?.seekForward(seconds: 5)
                                let impactMed = UIImpactFeedbackGenerator(style: .light)
                                impactMed.impactOccurred()
                            }
                        
                        Image(systemName: state == .playing ? "pause" : "play")
                            .foregroundColor(.white)
                            .padding(5)
                            .padding(.horizontal, 5)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .onTapGesture {
                                state == .playing ? player?.pause() : player?.resume()
                                let impactMed = UIImpactFeedbackGenerator(style: .light)
                                impactMed.impactOccurred()
                            }
                        
                        Text("Live")
                            .frame(width: 80)
                            .foregroundColor(.white)
                            .padding(5)
                            .padding(.horizontal, 5)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .onTapGesture {
                                player?.seekToLivePosition()
                                let impactMed = UIImpactFeedbackGenerator(style: .light)
                                impactMed.impactOccurred()
                            }
                    }
                    
                    
                }
            }
            .foregroundColor(.blue)
            .padding()
            
            Spacer(minLength: 0)
            
            VStack {
                ForEach(model.cues, id: \.self) { cue in
                    Text(cue.payload ?? "Empty Payload")
                        .foregroundColor(.white)
                }
            }
        }
    }
}
