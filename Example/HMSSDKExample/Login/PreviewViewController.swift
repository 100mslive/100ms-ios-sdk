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

    internal var user: String!
    internal var roomName: String!

    private var videoTrack: HMSLocalVideoTrack?
    private var audioTrack: HMSLocalAudioTrack?
    private var interactor: HMSSDKInteractor!

    @IBOutlet private weak var  previewView: HMSVideoView!

    @IBOutlet private weak var publishVideoButton: UIButton!
    @IBOutlet private weak var publishAudioButton: UIButton!
    @IBOutlet private weak var joinButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: joinButton)
        }
    }

    // MARK: - View Modifiers

    override func viewDidLoad() {

        joinButton.isEnabled = false
        publishVideoButton.isHidden = true
        publishAudioButton.isHidden = true
        previewView.mirror = true

        setupInteractor()

        observeBroadcast()
    }

    private func setupTracks(tracks: [HMSTrack]) {
        for track in tracks {
            if let videoTrack = track as? HMSLocalVideoTrack {
                self.videoTrack = videoTrack
                previewView.setVideoTrack(videoTrack)
                publishVideoButton.isHidden = false
            }

            if let audioTrack = track as? HMSLocalAudioTrack {
                self.audioTrack = audioTrack
                publishAudioButton.isHidden = false
            }
        }
    }

    private func setupInteractor() {
        interactor = HMSSDKInteractor(for: user, in: roomName) {}
        interactor.onPreview = { [weak self] _, tracks in
            self?.setupTracks(tracks: tracks)
            self?.joinButton.isEnabled = true
        }
    }

    private func observeBroadcast() {
        _ = NotificationCenter.default.addObserver(forName: Constants.gotError,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in
            if let strongSelf = self {
                let message = notification.userInfo?["error"] as? String
                let alert = UIAlertController(title: "ERROR! ❌",
                                              message: message,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay",
                                              style: .default,
                                              handler: { _ in
                                                self?.interactor.leave()
                                                self?.navigationController?.popToRootViewController(animated: true)
                                              }))
                strongSelf.present(alert, animated: true) {
                    print(#function)
                }
            }
        }
    }

    // MARK: - Action Handlers

    @IBAction private func backButtonTapped(_ sender: UIButton) {
        interactor.leave()
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func startMeetingTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.meeting, bundle: nil)
                .instantiateInitialViewController() as? MeetingViewController
        else {
           return
        }

        viewController.user = user
        viewController.roomName = roomName
        viewController.interactor = interactor

        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction private func cameraTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        videoTrack?.setMute(sender.isSelected)
    }

    @IBAction private func micTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        audioTrack?.setMute(sender.isSelected)
    }
}
