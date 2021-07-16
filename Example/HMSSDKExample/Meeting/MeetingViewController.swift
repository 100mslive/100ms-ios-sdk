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
    internal var interactor: HMSSDKInteractor!

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

    @IBOutlet private weak var publishVideoButton: UIButton!
    @IBOutlet private weak var publishAudioButton: UIButton!

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
                     image: UIImage(systemName: "speaker.zzz.fill")?.withTintColor(.link)) { [weak self] _ in
                guard let self = self else { return }
                if self.viewModel.mode != .audioOnly {
                    self.viewModel.mode = .audioOnly
                }
            },
            UIAction(title: "Show Active Speakers",
                     image: UIImage(systemName: "person.3.fill")?.withTintColor(.link), handler: { [weak self] (_) in
                        guard let self = self else { return }
                        if self.viewModel.mode != .speakers {
                            self.viewModel.mode = .speakers
                        }
                     }),
            UIAction(title: "Video Only Mode",
                     image: UIImage(systemName: "video.badge.checkmark")?.withTintColor(.link), handler: { [weak self] (_) in
                        guard let self = self else { return }
                        if self.viewModel.mode != .videoOnly {
                            self.viewModel.mode = .videoOnly
                        }
                     }),
            UIAction(title: "All Pinned Mode",
                     image: UIImage(systemName: "pin.circle.fill")?.withTintColor(.link), handler: { [weak self] (_) in
                        guard let self = self else { return }
                        if self.viewModel.mode != .pinned {
                            self.viewModel.mode = .pinned
                        }
                     }),
            UIAction(title: "Spotlight Mode",
                     image: UIImage(systemName: "figure.wave.circle.fill")?.withTintColor(.link)) { [weak self] _ in
                guard let self = self else { return }
                if self.viewModel.mode != .spotlight {
                    self.viewModel.mode = .spotlight
                }
            },
            UIAction(title: "Hero Mode",
                     image: UIImage(systemName: "shield.checkerboard")?.withTintColor(.link)) { [weak self] _ in
                guard let self = self else { return }
                if self.viewModel.mode != .hero {
                    self.viewModel.mode = .hero
                }
            },
            UIAction(title: "Default Mode",
                     image: UIImage(systemName: "rectangle.grid.2x2.fill")?.withTintColor(.link)) { [weak self] _ in
                guard let self = self else { return }
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

        viewModel = MeetingViewModel(self.user, self.roomName, collectionView, interactor: interactor)
        viewModel.onMoreButtonTap = { [weak self] peer, button in
            self?.showPeerActionsMenu(for: peer, on: button)
        }
        setupButtonStates()

        handleError()
        observeBroadcast()
        
        interactor.onRoleChange = { [weak self] request in
            self?.handle(roleChange: request)
        }
        
        viewModel.updateLocalPeerTracks = { [weak self] in
            self?.setupButtonStates()
        }
    }
    
    private func showPeerActionsMenu(for peer: HMSRemotePeer, on button: UIButton) {
        let title = "Select action"

        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .actionSheet)


        alertController.addAction(UIAlertAction(title: "Prompt to change role", style: .default) { [weak self, weak peer] _ in
            guard let peer = peer else { return }
            self?.showRoleChangePrompt(for: peer, force: false)
        })
        
        alertController.addAction(UIAlertAction(title: "Force change role", style: .default) { [weak self, weak peer] _ in
            guard let peer = peer else { return }
            self?.showRoleChangePrompt(for: peer, force: true)
        })
        
        alertController.addAction(UIAlertAction(title: "Select high layer", style: .default) { [weak peer] _ in
            peer?.remoteVideoTrack()?.layer = .high
        })
        
        alertController.addAction(UIAlertAction(title: "Select mid layer", style: .default) { [weak peer] _ in
            peer?.remoteVideoTrack()?.layer = .mid
        })
        
        alertController.addAction(UIAlertAction(title: "Select low layer", style: .default) { [weak peer] _ in
            peer?.remoteVideoTrack()?.layer = .low
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popoverController = alertController.popoverPresentationController {
            alertController.modalPresentationStyle = .popover
            popoverController.sourceView = button //to set the source of your alert
            popoverController.sourceRect = button.bounds
            popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
        }
        present(alertController, animated: true)
    }
    
    private func showRoleChangePrompt(for peer: HMSRemotePeer, force: Bool) {
        let title = "Role change request"

        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter role"
            textField.clearButtonMode = .always
            textField.text =  "teacher"
        }

        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Send", style: .default) { [weak self, weak alertController] _ in
            guard let roleName = alertController?.textFields?[0].text else {
                return
            }
            
            let trimmedRoleName = roleName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !trimmedRoleName.isEmpty else { return }
            
            guard let currentRoleName = peer.role?.name.lowercased(), trimmedRoleName != currentRoleName else {
                self?.showRoleIsSameError(for: peer, role: roleName)
                return
            }
            
            guard let targetRole = self?.interactor.roles?.first(where: { $0.name.lowercased() == trimmedRoleName }) else {
                return
            }
            
            self?.interactor?.changeRole(for: peer, to: targetRole, force: force)
        })

        present(alertController, animated: true)
    }
    
    private func showRoleIsSameError(for peer: HMSRemotePeer, role: String) {
        let title = "Error"

        let alertController = UIAlertController(title: title,
                                                message: "\(peer.name) is already a '\(role)'",
                                                preferredStyle: .alert)
        
         


        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))

        present(alertController, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            cleanup()
        }
    }
    
    private func cleanup() {
        UIApplication.shared.isIdleTimerDisabled = false
        viewModel.cleanup()
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
                                                self?.cleanup()
                                                self?.navigationController?.popToRootViewController(animated: true)
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

        _ = NotificationCenter.default.addObserver(forName: Constants.toggleVideoTapped,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            if let video = notification.userInfo?["video"] as? HMSVideoTrack,
               video.trackId == self?.viewModel.interactor?.hmsSDK?.localPeer?.videoTrack?.trackId {
                
                self?.publishVideoButton.isSelected = video.isMute()
            }
        }
        
        _ = NotificationCenter.default.addObserver(forName: Constants.toggleAudioTapped,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            if let audio = notification.userInfo?["audio"] as? HMSAudioTrack,
               audio.trackId == self?.viewModel.interactor?.hmsSDK?.localPeer?.audioTrack?.trackId {

                self?.publishAudioButton.isSelected = audio.isMute()
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
        guard viewModel.mode != .audioOnly,
              let videoTrack = viewModel.interactor?.hmsSDK?.localPeer?.videoTrack as? HMSLocalVideoTrack else {
            return
        }
        videoTrack.setMute(!sender.isSelected)
        UserDefaults.standard.set(sender.isSelected, forKey: Constants.publishVideo)
        sender.isSelected = !sender.isSelected
        NotificationCenter.default.post(name: Constants.updateVideoCellButton,
                                        object: nil,
                                        userInfo: ["video": videoTrack])
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

        alertController.addAction(UIAlertAction(title: "YES", style: .destructive) { [weak self] (_) in
            self?.cleanup()
            self?.navigationController?.popToRootViewController(animated: true)
        })

        alertController.addAction(UIAlertAction(title: "NO", style: .cancel))

        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupButtonStates() {
        guard let localPeer = viewModel.interactor?.hmsSDK?.localPeer else {
            return
        }
        
        if let videoTrack = localPeer.videoTrack as? HMSLocalVideoTrack {
            publishVideoButton.isSelected = videoTrack.isMute()
        } else {
            publishVideoButton.isSelected = true
        }
        
        if let audioTrack = localPeer.audioTrack as? HMSLocalAudioTrack {
            publishAudioButton.isSelected = audioTrack.isMute()
        } else {
            publishAudioButton.isSelected = true
        }
    }
    
    private func handle(roleChange request: HMSRoleChangeRequest) {
        let title = "Do you want to change your role to: \(request.suggestedRole.name)"

        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "No", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.interactor?.accept(changeRole: request)
            self?.setupButtonStates()
        })

        present(alertController, animated: true)
    }
}
