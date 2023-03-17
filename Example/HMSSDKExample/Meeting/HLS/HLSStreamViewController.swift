//
//  HLSStreamViewController.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 09.12.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import AVFoundation
import HMSSDK
import SwiftUI
import HMSHLSPlayerSDK

class HLSStreamViewController: UIViewController {
    
    var hmsPlayer = HMSHLSPlayer()
    weak var hmsSDK: HMSSDK?
    
    let overlayModel = HLSPlayerOverlayModel()
    
    let statsModel = HLSStatsModel()
    var statsTimer: Timer?
    
    let containerView = UIView()
    
    override func loadView() {
        
        view = containerView
        
        hmsPlayer.delegate = self
        hmsPlayer.analytics = hmsSDK
        
        self.statsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            
            guard let self = self else { return }
            
            let statMonitor = self.hmsPlayer.statMonitor
            
            self.statsModel.observedBitrate = statMonitor.estimatedBandwidth / 1024
            self.statsModel.streamBitrate = statMonitor.bitrate / 1024
            self.statsModel.bytesDownloaded = statMonitor.bytesDownloaded / 1024
            self.statsModel.bufferedDuration = statMonitor.bufferedDuration
            self.statsModel.distanceFromLiveEdge = statMonitor.distanceFromLiveEdge
            self.statsModel.droppedFrames = statMonitor.droppedFrames
            self.statsModel.videoSize = statMonitor.videoSize
            self.statsModel.watchDuration = statMonitor.watchDuration
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let playerView = hmsPlayer.videoPlayerViewController(showsPlayerControls: true)
        playerView.view.frame = view.bounds
        containerView.addConstrained(subview: playerView.view)
        
        if let overlayView = hmsPlayer.playerOverlayView {
            
            // Show cues and extra controls in overlay
            let cueController = UIHostingController(rootView: HLSPlayerOverlayView(player: hmsPlayer, model: overlayModel))
            cueController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            cueController.modalTransitionStyle = .crossDissolve
            cueController.view.backgroundColor = .clear
            
            overlayView.addSubview(cueController.view)
            cueController.view.translatesAutoresizingMaskIntoConstraints = false
            cueController.view.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 5).isActive = true
            cueController.view.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor).isActive = true
            cueController.view.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor).isActive = true
            cueController.view.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -5).isActive = true
            
            // Show stats in overlay
            let statController = UIHostingController(rootView: HLSStatsView(model: statsModel))
            statController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            statController.modalTransitionStyle = .crossDissolve
            statController.view.backgroundColor = .clear
            
            overlayView.addSubview(statController.view)
            statController.view.translatesAutoresizingMaskIntoConstraints = false
            statController.view.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
            statController.view.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
            
            statController.view.isHidden = !UserDefaults.standard.bool(forKey: Constants.showStats)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        statsTimer?.invalidate()
    }
    
    func play(url: URL) {
        hmsPlayer.play(url)
    }
    
    func stop() {
        hmsPlayer.stop()
    }
}

extension HLSStreamViewController: HMSHLSPlayerDelegate {
    
    func onResolutionChanged(videoSize: CGSize) {
        print("Resolution Changed: \(videoSize)")
    }
    
    func onPlaybackFailure(error: Error) {
        guard let error = error as? HMSHLSError else { return }
        
        if error.isTerminal {
            print("Player has encountered a terminal error, we need to restart the player: \(error.localizedDescription)")
        }
        else {
            print("Player has encountered an error, but it's non-fatal and player might recover \(error.localizedDescription)")
        }
    }
    
    func onCue(cue: HMSHLSCue) {
        
        overlayModel.cues.append(cue)
        
        if let endDate = cue.endDate {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + endDate.timeIntervalSince(cue.startDate)) { [weak self] in
                
                guard let self = self else { return }
                self.overlayModel.cues.removeAll { $0.id == cue.id }
            }
        }
    }
    
    func onPlaybackStateChanged(state: HMSHLSPlaybackState) {
        overlayModel.state = state
    }
}
