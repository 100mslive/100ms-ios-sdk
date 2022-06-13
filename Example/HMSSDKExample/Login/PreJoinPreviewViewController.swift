//
//  PreJoinPreviewViewController.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.09.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class PreJoinPreviewViewController: PreviewViewController {
    @IBOutlet weak var networkQualityView: NetworkQualityView!
    @IBOutlet weak var peerListButton: UIButton! {
        didSet {
            peerListButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
            peerListButton.isHidden = true
            Utilities.drawCorner(on: peerListButton)
        }
    }
    
    @IBOutlet private weak var joinButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: joinButton)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.isEnabled = false
        setupInteractor()
        startObservingNotifications()
        interactor.preview()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func cleanup() {
        interactor.leave()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    private func setupInteractor() {
        interactor.onPreview = { [weak self] _, tracks in
            self?.setupTracks(tracks: tracks)
            self?.joinButton.isEnabled = true
        }
        
        interactor.onMetadataUpdate = { [weak self] in
            self?.updateParticipants()
        }
        interactor.onNetworkQuality = { [weak self] in
            self?.updateNetworkQuality()
        }
    }
    
    private func updateParticipants() {
        guard let room = interactor.hmsSDK?.room else {
            return
        }
        
        let count = room.peerCount ?? 0
        peerListButton.isHidden = count == 0
        peerListButton.setTitle("\(count) peer(s) in room", for: .normal)
    }
    
    private func updateNetworkQuality() {
        guard let peer = interactor.hmsSDK?.localPeer else {
            return
        }
        
        networkQualityView.quality = peer.networkQuality?.downlinkQuality ?? -1
    }
    
    @objc private func onErrorNotification(notification: Notification) {
        let message = notification.userInfo?["error"] as? String
        let alert = UIAlertController(title: "ERROR! ❌",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay",
                                      style: .default,
                                      handler: { [weak self] _ in
                                        self?.cleanup()
                                        self?.navigationController?.popToRootViewController(animated: true)
                                      }))
        present(alert, animated: true) {
            print(#function)
        }
    }

    private func startObservingNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onErrorNotification(notification:)), name: Constants.gotError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onErrorNotification(notification:)), name: Constants.hmsError, object: nil)
    }
    
    private func stopObservingNotifications() {
        NotificationCenter.default.removeObserver(self, name: Constants.gotError, object: nil)
        NotificationCenter.default.removeObserver(self, name: Constants.hmsError, object: nil)
    }
    
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        cleanup()
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func startMeetingTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.meeting, bundle: nil)
                .instantiateInitialViewController() as? MeetingViewController
        else {
           return
        }

        viewController.interactor = interactor

        navigationController?.pushViewController(viewController, animated: true)
        stopObservingNotifications()
    }
    
    @IBAction private func peerListTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.peersList, bundle: nil)
                .instantiateViewController(withIdentifier: Constants.peersListPreview) as? PreviewPeersListViewController else {
            return
        }

        viewController.interactor = interactor

        present(viewController, animated: true)
    }

}
