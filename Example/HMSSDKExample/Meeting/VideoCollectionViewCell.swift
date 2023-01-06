//
//  VideoCollectionViewCell.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 03/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK
import QuartzCore

final class VideoCollectionViewCell: UICollectionViewCell {

    weak var viewModel: HMSViewModel? {
        didSet {
            videoStats = ""
            audioStats = ""
            
            if let peerName = viewModel?.peer.name {
                self.videoView.accessibilityIdentifier = peerName + "-cell"
                self.muteButton?.accessibilityIdentifier = peerName + "-cell-mute-mic-button"
                self.stopVideoButton?.accessibilityIdentifier = peerName + "-cell-mute-video-button"
                self.handIcon?.accessibilityIdentifier = peerName + "-cell-hand-icon"
                self.isDegradedIcon?.accessibilityIdentifier = peerName + "-cell-degraded-icon"
                self.networkQualityView?.accessibilityIdentifier = peerName + "-cell-network-quality-icon"
            }
        }
    }

    var videoStats: String = ""
    var audioStats: String = ""

    @IBOutlet weak var moreButton: UIButton!
    var onPinToggle: (() -> Void)?
    var onMuteToggle: (() -> Void)?

    var onMoreButtonTap: ((UIButton) -> Void)?

    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            Utilities.applyBorder(on: stackView)

            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = stackView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            stackView.addSubview(blurEffectView)
            stackView.sendSubviewToBack(blurEffectView)
        }
    }

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var statsLabel: UILabel!

    @IBOutlet weak var pinButton: UIButton!

    @IBOutlet weak var muteButton: UIButton!

    @IBOutlet weak var videoView: HMSVideoView! {
        didSet {
            Utilities.applyBorder(on: videoView, skipColor: true)
        }
    }

    @IBOutlet weak var stopVideoButton: UIButton!

    @IBOutlet weak var avatarLabel: UILabel! {
        didSet {
            avatarLabel.layer.cornerRadius = 32
        }
    }

    @IBOutlet weak var isDegradedIcon: UIImageView! {
        didSet {
            isDegradedIcon.isHidden = true
        }
    }
    @IBOutlet weak var handIcon: UIImageView! {
        didSet {
            handIcon.isHidden = true
        }
    }
    
    @IBOutlet weak var networkQualityView: NetworkQualityView! {
        didSet {
            networkQualityView.isHidden = true
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        Utilities.applyBorder(on: self)

        _ = NotificationCenter.default.addObserver(forName: Constants.toggleAudioTapped,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            if let userInfo = notification.userInfo,
               let updatedPeer = userInfo["peer"] as? HMSPeer,
               updatedPeer.peerID == self?.viewModel?.peer.peerID,
               let muteButton = self?.muteButton {
                muteButton.isSelected = !muteButton.isSelected
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.toggleVideoTapped,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in
            self?.updateVideoButton(notification)
        }
        
        _ = NotificationCenter.default.addObserver(forName: Constants.switchCameraTapped,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in
            
            if let cameraFacing = notification.userInfo?["cameraFacing"] as? HMSCameraFacing {
                if self?.videoView.videoTrack() is HMSLocalVideoTrack {
                    self?.videoView.mirror = cameraFacing == .front
                }
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.updateVideoCellButton,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in
            self?.updateVideoButton(notification)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(updateStats(notification:)), name: Constants.trackStatsUpdated, object: nil)
    }

    deinit {
        print(#function, Date(), "destroy cell", self)
        videoView.setVideoTrack(nil)

        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func pinTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        onPinToggle?()
    }

    @IBAction func muteTapped(_ sender: UIButton) {

        if let video = viewModel?.videoTrack {
            if video.source == HMSCommonTrackSource.screen || video.source == HMSCommonTrackSource.plugin {
                if let auxTracks = viewModel?.peer.auxiliaryTracks {
                    for track in auxTracks where track.kind == .audio {
                        if let remoteAudio = track as? HMSRemoteAudioTrack {
                            remoteAudio.setPlaybackAllowed(sender.isSelected)
                            updateMuteButtonStatus(sender, track as! HMSAudioTrack)
                        }
                        return
                    }
                }
            }
        }

        if let localPeer = viewModel?.peer as? HMSLocalPeer {
            if let audio = localPeer.localAudioTrack() {
                audio.setMute(!sender.isSelected)
                updateMuteButtonStatus(sender, audio)
            }
        } else if let remotePeer = viewModel?.peer as? HMSRemotePeer {
            if let remoteAudio = remotePeer.audioTrack as? HMSRemoteAudioTrack {
                if !remoteAudio.isMute() {
                    remoteAudio.setPlaybackAllowed(sender.isSelected)
                    updateMuteButtonStatus(sender, remoteAudio)
                }
            }
        }
    }

    @objc private func updateStats(notification: Notification) {
        guard UserDefaults.standard.bool(forKey: Constants.showStats),
              let peer = notification.userInfo?["peer"] as? HMSPeer,
              let stats = notification.userInfo?["stats"],
              viewModel?.peer.peerID == peer.peerID else {
            return
        }

        if let videoTrack = notification.userInfo?["track"] as? HMSVideoTrack {
            if videoTrack.trackId == viewModel?.videoTrack?.trackId {
                videoStats = statsDescription(stats: stats)
            }
        } else if let audioTrack = notification.userInfo?["track"] as? HMSAudioTrack {
            if audioTrack.source == viewModel?.videoTrack?.source || (viewModel?.videoTrack == nil && audioTrack.source == HMSCommonTrackSource.regular) {
                audioStats = statsDescription(stats: stats)
            }
        }

        statsLabel.text = [videoStats, audioStats].joined(separator: "\n")
    }

    private func updateMuteButtonStatus(_ sender: UIButton, _ audio: HMSAudioTrack) {

        sender.isSelected = !sender.isSelected

        NotificationCenter.default.post(name: Constants.toggleAudioTapped,
                                        object: nil,
                                        userInfo: ["audio": audio])
    }

    @IBAction func stopVideoTapped(_ sender: UIButton) {

        if let localVideo = viewModel?.videoTrack as? HMSLocalVideoTrack {
            localVideo.setMute(!sender.isSelected)

            updateStopVideoButtonStatus(sender, localVideo)

        } else if let remoteVideo = viewModel?.videoTrack as? HMSRemoteVideoTrack {
            if !remoteVideo.isMute() {

                remoteVideo.setPlaybackAllowed(sender.isSelected)

                updateStopVideoButtonStatus(sender, remoteVideo)
            }
        }
    }

    private func updateStopVideoButtonStatus(_ sender: UIButton, _ remoteVideo: HMSVideoTrack) {
        avatarLabel.isHidden = sender.isSelected
        UserDefaults.standard.set(sender.isSelected, forKey: Constants.publishVideo)

        sender.isSelected = !sender.isSelected

        NotificationCenter.default.post(name: Constants.toggleVideoTapped,
                                        object: nil,
                                        userInfo: ["video": remoteVideo])
    }

    @IBAction func moreButtonTapped(_ sender: UIButton) {
        onMoreButtonTap?(sender)
    }

    private func updateVideoButton(_ notification: Notification) {
        if let video = notification.userInfo?["video"] as? HMSLocalVideoTrack,
           video.trackId == viewModel?.videoTrack?.trackId {
            stopVideoButton.isSelected = video.isMute()
            avatarLabel.isHidden = !video.isMute()
        }
    }

    private func statsDescription(stats: Any) -> String {
        var components = [String]()
        let layerNameMap = [ HMSSimulcastLayer.high : "High", HMSSimulcastLayer.mid : "Medium", HMSSimulcastLayer.low : "Low"]

        if let localAudioStats = stats as? HMSLocalAudioStats {
            components += ["Bitrate (Audio) \(String(format: "%.1f Kb/s", localAudioStats.bitrate))"]
        } else if let localVideoStats = stats as? [HMSLocalVideoStats] {
            for layerStats in localVideoStats {
                if let layerId = layerStats.simulcastLayerId?.uintValue, let layerType = HMSSimulcastLayer(rawValue: layerId), let layerName = layerNameMap[layerType] {
                    components += [layerName]
                }
                let resolutionString = "\(layerStats.resolution.width)x\(layerStats.resolution.height)"
                let frameRateString = String(format: "%.0f", layerStats.frameRate)
                components += ["Resolution @ FPS \(resolutionString)@\(frameRateString)"]
                components += ["Bitrate (Video) \(String(format: "%.1f Kb/s", layerStats.bitrate))"]
                
                let qualityLimitations = layerStats.qualityLimitations
                if qualityLimitations.cpu > 2 {
                    let activeMark = qualityLimitations.reason == .CPU ? "> " : ""
                    components += ["\(activeMark)Limited by CPU \(String(format: "%.1f", qualityLimitations.cpu))"]
                }
                if qualityLimitations.bandwidth > 2 {
                    let activeMark = qualityLimitations.reason == .bandwidth ? "> " : ""
                    components += ["\(activeMark)Limited by bandwidth \(String(format: "%.1f", qualityLimitations.bandwidth))"]
                }
                if qualityLimitations.other > 2 {
                    let activeMark = qualityLimitations.reason == .other ? "> " : ""
                    components += ["\(activeMark)Limited by other \(String(format: "%.1f", qualityLimitations.other))"]
                }
                components += [" "]
            }
        } else if let remoteAudioStats = stats as? HMSRemoteAudioStats {
            components += ["Bitrate (Audio) \(String(format: "%.1f Kb/s", remoteAudioStats.bitrate))"]
            components += ["Packets Lost (Audio) \(remoteAudioStats.packetsLost)"]
            components += ["Jitter (Audio) \(remoteAudioStats.jitter)"]
        } else if let remoteVideoStats = stats as? HMSRemoteVideoStats {
            let resolutionString = "\(remoteVideoStats.resolution.width)x\(remoteVideoStats.resolution.height)"
            let frameRateString = String(format: "%.0f", remoteVideoStats.frameRate)
            components += ["Resolution @ FPS \(resolutionString)@\(frameRateString)"]
            components += ["Bitrate (Video) \(String(format: "%.1f Kb/s", remoteVideoStats.bitrate))"]
            components += ["Packets Lost (Video) \(remoteVideoStats.packetsLost)"]
            components += ["Jitter (Video) \(remoteVideoStats.jitter)"]
        }

        return components.joined(separator: "\n")
    }

}
