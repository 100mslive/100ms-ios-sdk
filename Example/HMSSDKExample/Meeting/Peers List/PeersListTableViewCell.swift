//
//  PeersListTableViewCell.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 07/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK

final class PeersListTableViewCell: UITableViewCell {

    weak var peer: HMSPeer?

    var onSettingsButtonTap: ((UIButton) -> Void)?

    @IBOutlet weak var speakingImageView: UIImageView! {
        didSet {
            speakingImageView.addGestureRecognizer(UITapGestureRecognizer(
                                                    target: self,
                                                    action: #selector(micButtonTapped(_:))))
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    private var wasHighlighted = false

    @objc func micButtonTapped(_ sender: UITapGestureRecognizer) {
        if let localPeer = peer as? HMSLocalPeer, let audio = localPeer.localAudioTrack() {
            audio.setMute(!audio.isMute())
            NotificationCenter.default.post(name: Constants.toggleAudioTapped,
                                            object: nil,
                                            userInfo: ["peer": localPeer])
        } else if let remotePeer = peer as? HMSRemotePeer, let audio = remotePeer.remoteAudioTrack() {
            audio.setPlaybackAllowed(!audio.isPlaybackAllowed())
            NotificationCenter.default.post(name: Constants.toggleAudioTapped,
                                            object: nil,
                                            userInfo: ["peer": remotePeer])
        }

        speakingImageView.isHighlighted = !wasHighlighted
        wasHighlighted = speakingImageView.isHighlighted
    }

    @IBAction func videoButtonTapped(_ sender: UIButton) {
        if let localPeer = peer as? HMSLocalPeer {
            localPeer.localVideoTrack()?.setMute(!sender.isSelected)
        } else if let remotePeer = peer as? HMSRemotePeer {
            remotePeer.remoteAudioTrack()?.setPlaybackAllowed(sender.isSelected)
        }

        sender.isSelected = !sender.isSelected
        NotificationCenter.default.post(name: Constants.toggleVideoTapped, object: nil)
    }

    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        onSettingsButtonTap?(sender)
    }
}
