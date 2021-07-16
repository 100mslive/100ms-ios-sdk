//
//  VideoCollectionViewCell.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 03/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK
import QuartzCore

final class VideoCollectionViewCell: UICollectionViewCell {

    weak var viewModel: HMSViewModel? 

    @IBOutlet weak var moreButton: UIButton!
    var onPinToggle: (() -> Void)?
    var onMuteToggle: (() -> Void)?
    
    var onMoreButtonTap: ((UIButton)-> Void)?

    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            Utilities.applyBorder(on: stackView)
            stackView.backgroundColor = stackView.backgroundColor?.withAlphaComponent(0.5)
        }
    }

    @IBOutlet weak var nameLabel: UILabel!

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
        
        _ = NotificationCenter.default.addObserver(forName: Constants.updateVideoCellButton,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in
            self?.updateVideoButton(notification)
        }
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
        
        if let localPeer = viewModel?.peer as? HMSLocalPeer {
            localPeer.localAudioTrack()?.setMute(!sender.isSelected)
        } else if let remotePeer = viewModel?.peer as? HMSRemotePeer {
            remotePeer.remoteAudioTrack()?.setPlaybackAllowed(sender.isSelected)
        }

        sender.isSelected = !sender.isSelected
        
        if let audio = viewModel?.peer.audioTrack {
            NotificationCenter.default.post(name: Constants.toggleAudioTapped,
                                            object: nil,
                                            userInfo: ["audio": audio])
        }
    }

    @IBAction func stopVideoTapped(_ sender: UIButton) {
        
        if let localPeer = viewModel?.peer as? HMSLocalPeer {
            localPeer.localVideoTrack()?.setMute(!sender.isSelected)
        } else if let remotePeer = viewModel?.peer as? HMSRemotePeer {
            remotePeer.remoteVideoTrack()?.setPlaybackAllowed(sender.isSelected)
        }

        avatarLabel.isHidden = sender.isSelected
        UserDefaults.standard.set(sender.isSelected, forKey: Constants.publishVideo)
        sender.isSelected = !sender.isSelected
        if let video = viewModel?.videoTrack {
            NotificationCenter.default.post(name: Constants.toggleVideoTapped,
                                            object: nil,
                                            userInfo: ["video": video])
        }
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
}
