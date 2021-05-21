//
//  MeetingViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import HMSSDK
import MediaPlayer

final class MeetingViewController: UIViewController {

    // MARK: - View Properties

    internal var user: String!
    internal var roomName: String!
    internal var flow: MeetingFlow!
    internal var role: Int!

    private var viewModel: MeetingViewModel!

    @IBOutlet private weak var roomNameButton: UIButton! {
        didSet {
            roomNameButton.setTitle(roomName, for: .normal)
            roomNameButton.titleLabel?.lineBreakMode = .byTruncatingTail
            roomNameButton.titleLabel?.numberOfLines = 1
            roomNameButton.titleLabel?.adjustsFontSizeToFitWidth = false
        }
    }

    @IBOutlet private weak var speakerButton: UIButton!

    @IBOutlet private weak var collectionView: UICollectionView!

    @IBOutlet private weak var badgeButton: BadgeButton!

    @IBOutlet private weak var publishVideoButton: UIButton! {
        didSet {
            if let publishVideo = UserDefaults.standard.object(forKey: Constants.publishVideo) as? Bool {
                publishVideoButton.isSelected = !publishVideo
            } else {
                publishVideoButton.isSelected = false
            }
        }
    }

    @IBOutlet private weak var publishAudioButton: UIButton! {
        didSet {
//            if let publishAudio = UserDefaults.standard.object(forKey: Constants.publishAudio) as? Bool {
//                publishAudioButton.isSelected = !publishAudio
//            } else {
                publishAudioButton.isSelected = false
//            }
        }
    }

    @IBOutlet weak var loadingIcon: UIImageView! {
        didSet {
            loadingIcon.rotate()
        }
    }
    @IBOutlet weak var settingsButton: UIButton! {
        didSet {
            settingsButton.imageView?.rotate()
            if #available(iOS 14.0, *) {
                settingsButton.menu = menu
                settingsButton.showsMenuAsPrimaryAction = true
            } else {
                // Fallback on earlier versions
            }
        }
    }

    var menuItems: [UIAction] {
        return [
            UIAction(title: "Audio Only Mode",
                     image: UIImage(systemName: "speaker.zzz.fill")?.withTintColor(.link)) { _ in
                if self.viewModel.mode != .audioOnly {
                    self.viewModel.mode = .audioOnly
                }
            },
            UIAction(title: "Show Active Speakers",
                     image: UIImage(systemName: "person.3.fill")?.withTintColor(.link), handler: { (_) in
                if self.viewModel.mode != .speakers {
                    self.viewModel.mode = .speakers
                }
            }),
            UIAction(title: "Video Only Mode",
                     image: UIImage(systemName: "video.badge.checkmark")?.withTintColor(.link), handler: { (_) in
                if self.viewModel.mode != .videoOnly {
                    self.viewModel.mode = .videoOnly
                }
            }),
            UIAction(title: "All Pinned Mode",
                     image: UIImage(systemName: "pin.circle.fill")?.withTintColor(.link), handler: { (_) in
                if self.viewModel.mode != .pinned {
                    self.viewModel.mode = .pinned
                }
            }),
            UIAction(title: "Default Mode",
                     image: UIImage(systemName: "rectangle.grid.2x2.fill")?.withTintColor(.link)) { _ in

                if self.viewModel.mode != .regular {
                    self.viewModel.mode = .regular
                }
            }
        ]
    }

    var menu: UIMenu {
        UIMenu(title: "Change Layout", image: nil, identifier: nil, options: [], children: menuItems)
    }

    private var chatBadgeCount = 0

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true

        viewModel = MeetingViewModel(self.user, self.roomName, flow, role, collectionView)

        handleError()
        observeBroadcast()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            UIApplication.shared.isIdleTimerDisabled = false
            viewModel.cleanup()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Action Handlers

    private func handleError() {
        _ = NotificationCenter.default.addObserver(forName: Constants.hmsError,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            if let message = notification.userInfo?["error"] as? String {

                print(#function, "Error: ", message)

                if let presentedVC = self?.presentedViewController {
                    presentedVC.dismiss(animated: true) {
                        self?.presentAlert(message)
                    }
                    return
                }

                self?.presentAlert(message)
            }
        }
    }

    private func presentAlert(_ message: String) {
        let alertController = UIAlertController(title: "Error",
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        present(alertController, animated: true, completion: nil)
    }

    private func observeBroadcast() {
        _ = NotificationCenter.default.addObserver(forName: Constants.messageReceived,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            if let strongSelf = self {
                strongSelf.chatBadgeCount += 1
                strongSelf.badgeButton.badge = "\(strongSelf.chatBadgeCount)"
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.joinedRoom,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            if let strongSelf = self {
                strongSelf.loadingIcon.hide()
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.gotError,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in
            if let strongSelf = self {
                strongSelf.loadingIcon.hide()
                let message = notification.userInfo?["error"] as? String
                let alert = UIAlertController(title: "ERROR! ❌",
                                              message: message,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay",
                                              style: .default,
                                              handler: { _ in
                                                self?.navigationController?.popViewController(animated: true)
                                              }))
                strongSelf.present(alert, animated: true) {
                    print(#function)
                }
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.updatedSpeaker,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in

            if let speaker = self?.viewModel.speakers.first {
                self?.roomNameButton.setTitle(" 🔊 " + speaker.peer.name, for: .normal)
            } else {
                self?.roomNameButton.setTitle(self?.roomName, for: .normal)
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.stopVideoTapped,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            if let video = notification.userInfo?["video"] as? HMSVideoTrack,
               video.trackId == self?.viewModel.interactor?.hms?.localPeer?.videoTrack?.trackId {

                self?.publishVideoButton.isSelected = video.isMute()
            }
        }
    }

    @IBAction private func roomNameTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.peersList, bundle: nil)
                .instantiateInitialViewController() as? PeersListViewController else {
            return
        }

        viewController.interactor = viewModel.interactor
        viewController.speakers = viewModel.speakers

        present(viewController, animated: true)
    }

    @IBAction private func muteRemoteStreamsTapped(_ sender: UIButton) {
        viewModel.muteRemoteStreams(sender.isSelected)
        sender.isSelected = !sender.isSelected
    }

    @IBAction private func switchCameraTapped(_ sender: UIButton) {
        viewModel.switchCamera()
    }

    @IBAction private func videoTapped(_ sender: UIButton) {
        viewModel.switchVideo(isOn: sender.isSelected)
        UserDefaults.standard.set(sender.isSelected, forKey: Constants.publishVideo)
        sender.isSelected = !sender.isSelected
    }

    @IBAction private func micTapped(_ sender: UIButton) {
        viewModel.switchAudio(isOn: sender.isSelected)
        UserDefaults.standard.set(sender.isSelected, forKey: Constants.publishAudio)
        sender.isSelected = !sender.isSelected
    }

    @IBAction private func chatTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.chat, bundle: nil)
                .instantiateInitialViewController() as? ChatViewController else {
            return
        }

        viewController.interactor = viewModel.interactor

        chatBadgeCount = 0

        badgeButton.badge = nil

        present(viewController, animated: true)
    }

    @IBAction private func disconnectTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Leave Call",
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "YES", style: .destructive) { (_) in
            self.navigationController?.popViewController(animated: true)
        })

        alertController.addAction(UIAlertAction(title: "NO", style: .cancel))

        self.present(alertController, animated: true, completion: nil)

    }
}
