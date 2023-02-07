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

class HLSStreamViewController: UIViewController, AVPlayerItemMetadataCollectorPushDelegate {
    
    var player: AVPlayer?
    var playerView: PlayerView!
    var metadataView: UILabel!
    var metadataCollector: AVPlayerItemMetadataCollector!
    var retriesLeft = 0
    var playerItem: AVPlayerItem?
    var currentMetadataGroup: AVDateRangeMetadataGroup?
    var metadataGroups = [AVDateRangeMetadataGroup]()
    
    var statMonitor: HMSHLSStatsMonitor?
    let statsModel = HLSStatsModel()
    var statsTimer: Timer?
    
    weak var hmsSDK: HMSSDK?

    var streamURL: URL? {
        didSet {
            if oldValue == streamURL {
                return
            }
            stop()
            retriesLeft = 10
        }
    }

    override func loadView() {
        let containerView = UIView()
        view = containerView
        
        playerView = PlayerView()
        containerView.addConstrained(subview: playerView)

        metadataView = UILabel()
        containerView.addSubview(metadataView)
        metadataView.translatesAutoresizingMaskIntoConstraints = false
        metadataView.backgroundColor = .lightGray
        metadataView.textColor = .black
        metadataView.textAlignment = .center
        metadataView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor).isActive = true
        metadataView.leftAnchor.constraint(equalTo: playerView.leftAnchor).isActive = true
        metadataView.rightAnchor.constraint(equalTo: playerView.rightAnchor).isActive = true
        metadataView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        metadataView.isHidden = true
        
        let statController = UIHostingController(rootView: HLSStatsView(model: statsModel))
        statController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        statController.modalTransitionStyle = .crossDissolve
        statController.view.backgroundColor = .clear
        containerView.addConstrained(subview: statController.view)
        
        statController.view.isHidden = !UserDefaults.standard.bool(forKey: Constants.showStats)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        statsTimer?.invalidate()
    }
    
    func play() {
        guard let streamURL = streamURL else {
            return
        }
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true) //Set to false to deactivate session
        } catch let error as NSError {
            print("Unable to activate audio session:  \(error.localizedDescription)")
        }

        // Create asset to be played
        print("Trying to play: \(streamURL.absoluteString)")
        let asset = AVAsset(url: streamURL)

        let assetKeys = [
            "playable"
        ]
        
        metadataCollector = AVPlayerItemMetadataCollector()
        metadataCollector.setDelegate(self, queue: DispatchQueue.main)
        
        // Create a new AVPlayerItem with the asset and an
        // array of asset keys to be automatically loaded
        let item = AVPlayerItem(asset: asset,
                                automaticallyLoadedAssetKeys: assetKeys)
        item.add(metadataCollector)

        // Register as an observer of the player item's status property
        item.addObserver(self,
                         forKeyPath: #keyPath(AVPlayerItem.status),
                         options: [.old, .new],
                         context: nil)
        playerItem = item

        if player == nil {
            player = AVPlayer(playerItem: item)
            
            if UserDefaults.standard.bool(forKey: Constants.showStats) {
                statMonitor = hmsSDK?.hlsStatsMonitor(player: player!)
                statMonitor!.delegate = self

                statsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    
                    guard let self = self, let statMonitor = self.statMonitor else { return }
                    
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
            
            playerView.player = player
            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main, using: { [weak self] time in
                self?.updateMetadataView(for: time)
            })
        } else {
            player?.replaceCurrentItem(with: item)
        }
    }

    func stop() {
        player?.pause()
    }
    
    func updateMetadataView(for currentTime: CMTime) {
        hideCurrentMetadataViewIfNeeded()
        
        guard currentMetadataGroup == nil, let playerItem = playerItem else { return }
        
        for group in metadataGroups {
            if group.shouldShow(for: playerItem) {
                showMetadataView(for: group)
                break
            }
        }
    }
    
    func showMetadataView(for group: AVDateRangeMetadataGroup) {
        guard currentMetadataGroup != group else { return }
        
        currentMetadataGroup = group
        metadataView.isHidden = false
        metadataView.text = group.hmsPayloadString()
    }
    
    func hideCurrentMetadataViewIfNeeded() {
        guard let currentMetadataGroup = currentMetadataGroup,
              let playerItem = playerItem,
              !currentMetadataGroup.shouldShow(for: playerItem) else { return }
        self.currentMetadataGroup = nil
        metadataView.isHidden = true
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status

            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over the status
            switch status {
            case .readyToPlay:
                player?.play()
                // Player item is ready to play.
            case .failed:
                if let error = playerItem?.error {
                    print("Playback error \(error)")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) { [weak self] in
                    guard let self = self else {
                        return
                    }

                    if self.retriesLeft > 0 {
                        self.retriesLeft = self.retriesLeft - 1
                        self.play()
                    }
                }
            case .unknown:
                print("Unknown player item status")
                break
            @unknown default:
                print("Unknown player item status")
                break
            }
        }
    }
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        playerView.player = nil
    }
    
    @objc func applicationDidBecomeActive(_ notificiation: Notification) {
        playerView.player = player
    }
    
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector,
                           didCollect metadataGroups: [AVDateRangeMetadataGroup],
                           indexesOfNewGroups: IndexSet,
                           indexesOfModifiedGroups: IndexSet) {
        self.metadataGroups = metadataGroups
    }
}

extension HLSStreamViewController: HMSHLSPlaybackDelegate {
    
    func playerDidChangeResolution(videoSize: CGSize) {
        print("Resolution Changed: \(videoSize)")
    }
    
    func onPlaybackFailure(error: Error) {
        guard let error = error as? HMSError else { return }
        
        if error.isTerminal {
            print("Player has encountered a terminal error, we need to restart the player: \(error.localizedDescription)")
        }
        else {
            print("Player has encountered an error, but it's non-fatal and player might recover \(error.localizedDescription)")
        }
    }
}

class PlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var player: AVPlayer? {
        get {
            (layer as? AVPlayerLayer)?.player
        }
        set {
            (layer as? AVPlayerLayer)?.player = newValue
        }
    }
}

extension AVDateRangeMetadataGroup {
    func shouldShow(for item: AVPlayerItem) -> Bool {
        guard let endDate = endDate, let currentDate = item.currentDate() else { return false }
        return startDate <= currentDate && currentDate < endDate
    }
}
