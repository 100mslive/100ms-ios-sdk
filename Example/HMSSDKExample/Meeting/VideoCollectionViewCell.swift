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

    var onPinToggle: (() -> Void)?
    var onMuteToggle: (() -> Void)?

    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            Utilities.applyBorder(on: stackView)
            stackView.backgroundColor = stackView.backgroundColor?.withAlphaComponent(0.5)
        }
    }

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var pinButton: UIButton!

    @IBOutlet weak var muteButton: UIButton!

    @IBOutlet weak var videoView: HMSVideoView!

    @IBOutlet weak var stopVideoButton: UIButton!

    @IBOutlet weak var avatarLabel: UILabel! {
        didSet {
            avatarLabel.layer.cornerRadius = 32
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        Utilities.applyBorder(on: self)

//        _ = NotificationCenter.default.addObserver(forName: Constants.muteALL,
//                                               object: nil,
//                                               queue: .main) { [weak self] _ in
//            if let audioEnabled = self?.model?.stream.audioTracks?.first?.enabled {
//                self?.muteButton.isSelected = !audioEnabled
//            }
//        }
//
        _ = NotificationCenter.default.addObserver(forName: Constants.peerAudioToggled,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            if let userInfo = notification.userInfo,
               let updatedPeer = userInfo["peer"] as? HMSPeer,
               updatedPeer.peerID == self?.viewModel?.peer.peerID,
               let muteButton = self?.muteButton {
                muteButton.isSelected = !muteButton.isSelected
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.peerVideoToggled,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in
            if let video = notification.userInfo?["video"] as? HMSLocalVideoTrack,
               video.trackId == self?.viewModel?.videoTrack?.trackId {
                self?.stopVideoButton.isSelected = video.isMute()
                self?.avatarLabel.isHidden = !video.isMute()
            }
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
        print(#function, sender.isSelected, viewModel?.peer.name as Any)
        if let localPeer = viewModel?.peer as? HMSLocalPeer {
            localPeer.localAudioTrack()?.setMute(!sender.isSelected)
        } else if let remotePeer = viewModel?.peer as? HMSRemotePeer {
            remotePeer.remoteAudioTrack()?.setPlaybackAllowed(sender.isSelected)
        }

        sender.isSelected = !sender.isSelected
    }

    @IBAction func stopVideoTapped(_ sender: UIButton) {
        print(#function, sender.isSelected, viewModel?.peer.name as Any)
        if let localPeer = viewModel?.peer as? HMSLocalPeer {
            localPeer.localVideoTrack()?.setMute(!sender.isSelected)
        } else if let remotePeer = viewModel?.peer as? HMSRemotePeer {
            remotePeer.remoteVideoTrack()?.setPlaybackAllowed(sender.isSelected)
        }

        avatarLabel.isHidden = sender.isSelected
        sender.isSelected = !sender.isSelected
        if let video = viewModel?.videoTrack {
            NotificationCenter.default.post(name: Constants.stopVideoTapped,
                                            object: nil,
                                            userInfo: ["video": video])
        }
    }
}
