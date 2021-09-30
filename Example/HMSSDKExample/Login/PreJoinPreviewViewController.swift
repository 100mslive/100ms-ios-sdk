//
//  PreJoinPreviewViewController.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.09.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class PreJoinPreviewViewController: PreviewViewController {

    internal var user: String!
    internal var roomName: String!

    @IBOutlet private weak var joinButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: joinButton)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.isEnabled = false
        setupInteractor()
        observeBroadcast()
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

}
