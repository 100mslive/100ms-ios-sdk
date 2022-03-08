//
//  HLSStreamViewController.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 09.12.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import AVFoundation

class HLSStreamViewController: UIViewController {

    var player: AVPlayer?
    var playerView: PlayerView!
    var retriesLeft = 0

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
        playerView = PlayerView()
        view = playerView
    }

    var playerItem: AVPlayerItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func play() {
        guard let streamURL = streamURL else {
            return
        }
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
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
        // Create a new AVPlayerItem with the asset and an
        // array of asset keys to be automatically loaded
        let item = AVPlayerItem(asset: asset,
                                automaticallyLoadedAssetKeys: assetKeys)

        // Register as an observer of the player item's status property
        item.addObserver(self,
                         forKeyPath: #keyPath(AVPlayerItem.status),
                         options: [.old, .new],
                         context: nil)
        playerItem = item

        if player == nil {
            player = AVPlayer(playerItem: item)
            playerView.player = player
        } else {
            player?.replaceCurrentItem(with: item)
        }
    }

    func stop() {
        player?.pause()
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
