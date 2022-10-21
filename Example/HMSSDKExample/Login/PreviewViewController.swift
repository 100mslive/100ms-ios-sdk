//
//  PreviewViewController.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 30.06.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK

class PreviewViewController: UIViewController {

    // MARK: - Instance Properties

    var videoTrack: HMSLocalVideoTrack?
    var audioTrack: HMSLocalAudioTrack?
    var interactor: HMSSDKInteractor!

    @IBOutlet weak var  previewView: HMSVideoView!

    @IBOutlet weak var publishVideoButton: UIButton!
    @IBOutlet weak var publishAudioButton: UIButton!


    // MARK: - View Modifiers

    override func viewDidLoad() {
        publishVideoButton.isHidden = true
        publishAudioButton.isHidden = true
        previewView.mirror = true
    }

    func setupTracks(tracks: [HMSTrack]) {
        for track in tracks {
            if let videoTrack = track as? HMSLocalVideoTrack {
                self.videoTrack = videoTrack
                previewView.setVideoTrack(videoTrack)
                publishVideoButton.isSelected = videoTrack.isMute()
                publishVideoButton.isHidden = false
            }

            if let audioTrack = track as? HMSLocalAudioTrack {
                self.audioTrack = audioTrack
                publishAudioButton.isSelected = audioTrack.isMute()
                publishAudioButton.isHidden = false
            }
        }
    }

    // MARK: - Action Handlers

    @IBAction func cameraTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        videoTrack?.setMute(sender.isSelected)
    }

    @IBAction func micTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        audioTrack?.setMute(sender.isSelected)
    }
}
