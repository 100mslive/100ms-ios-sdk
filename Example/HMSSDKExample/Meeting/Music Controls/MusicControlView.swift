//
//  MusicController.swift
//  HMSSDKExample
//
//  Created by Pawan Dixit on 30/06/22.
//  Copyright © 2022 100ms. All rights reserved.
//

import SwiftUI
import HMSSDK

struct MusicControlView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let hmsPlayer: HMSAudioFilePlayerNode
    @ObservedObject var audioPlayer: AudioPlayer
    
    init(player: HMSAudioFilePlayerNode) {
        self.hmsPlayer = player
        audioPlayer = AudioPlayer(audioPlayer: player)
        
        self.audioPlayer.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                VolumeView(sliderProgress: Binding(get: {
                    CGFloat(hmsPlayer.volume)
                }, set: { value in
                    hmsPlayer.volume = Float(value)
                }))
                Text("Volume")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.bottom)
                
                Slider(value: $audioPlayer.playValue, in: TimeInterval(0.0)...audioPlayer.playerDuration, onEditingChanged: { _ in
                    self.audioPlayer.changeSliderValue()
                })
                .padding()
                .onAppear() {
                    refresh()
                }
                .onReceive(audioPlayer.timer) { _ in
                    refresh()
                }
                
                HStack {
                    Button(action: {
                        if audioPlayer.playing {
                            self.audioPlayer.pauseSound()
                        }
                        else {
                            audioPlayer.play()
                        }
                    }) {
                        Image(systemName: audioPlayer.playing ? "pause.circle" : "play.circle")
                            .foregroundColor(Color.white)
                            .font(.system(size: 44))
                    }
                    Button(action: {
                        audioPlayer.stopSound()
                        self.audioPlayer.playValue = 0.0
                        
                    }) {
                        Image(systemName: "stop.circle")
                            .foregroundColor(Color.white)
                            .font(.system(size: 44))
                    }
                }
                .padding()
            }
            .padding()
        }
        .onTapGesture {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func refresh() {
        self.audioPlayer.playing = hmsPlayer.isPlaying
        audioPlayer.playerDuration = hmsPlayer.duration
        
        if self.audioPlayer.playing {
            let currentTime = self.audioPlayer.audioPlayer.currentTime
            self.audioPlayer.playValue = currentTime
            
            if currentTime == TimeInterval(0.0) {
                self.audioPlayer.playing = false
            }
        }
    }
}

class AudioPlayer: ObservableObject {
    
    let audioPlayer: HMSAudioFilePlayerNode
    
    init(audioPlayer: HMSAudioFilePlayerNode) {
        self.audioPlayer = audioPlayer
    }
    
    @Published var playing = false
    @Published var playValue: TimeInterval = 0.0
    var playerDuration: TimeInterval = 0
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func play() {
        playing = true
        try? audioPlayer.resume()
    }

    func stopSound() {
        audioPlayer.stop()
        playing = false
        playValue = 0.0
    }
    
    func pauseSound() {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            playing = false
        }
    }
    
    func changeSliderValue() {
        // Seeking timeline on HMSAudioFilePlayerNode is currently not supported
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> some UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.effect = effect
    }
}
