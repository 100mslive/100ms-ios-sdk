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

    @IBOutlet weak var hlsContainer: UIView!

    private var viewModel: MeetingViewModel?
    private var hlsController: HLSStreamViewController?

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

    @IBOutlet private weak var publishVideoButton: UIButton!
    @IBOutlet private weak var publishAudioButton: UIButton!

    @IBOutlet private weak var loadingIcon: UIImageView! {
        didSet {
            loadingIcon.rotate()
        }
    }

    @IBOutlet private weak var settingsButton: UIButton! {
        didSet {
            updateSettingsButton()
        }
    }

    private var menu: UIMenu {
        UIMenu(children: menuItems() + roleBasedActions())
    }

    // MARK: - View Lifecycle

    func setupHLSController() {
        let vc = HLSStreamViewController()
        addChild(vc)
        hlsContainer.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: hlsContainer.topAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: hlsContainer.bottomAnchor).isActive = true
        vc.view.leftAnchor.constraint(equalTo: hlsContainer.leftAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: hlsContainer.rightAnchor).isActive = true
        vc.didMove(toParent: self)
        hlsController = vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true

        viewModel = MeetingViewModel(self.user, self.roomName, collectionView, interactor: interactor)

        setupButtonStates()

        handleError()
        observeBroadcast()

        setupHLSController()

        interactor.onRoleChange = { [weak self] request in
            self?.handle(roleChange: request)
        }

        interactor.onChangeTrackState = { [weak self] request in
            self?.handle(changeTrackState: request)
        }

        interactor.onRemovedFromRoom = { [weak self] notification in
            self?.handle(removedFromRoom: notification)
        }

        interactor.onRecordingUpdate = { [weak self] in
            self?.updateSettingsButton()
        }

        interactor.onHLSUpdate = { [weak self] in
            self?.updateHLSState()
        }

        viewModel?.updateLocalPeerTracks = { [weak self] in
            self?.setupButtonStates()
        }

        viewModel?.showRoleChangePrompt = { [weak self] peer, force in
            self?.showRoleChangePrompt(for: peer, force: force)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            settingsButton.imageView?.rotate()
            navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            cleanup()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - View Modifiers

    func updateHLSState() {
        guard interactor?.hmsSDK?.localPeer?.role?.name.hasPrefix("hls-") ?? false else {
            hlsContainer.isHidden = true
            hlsController?.streamURL = nil
            hlsController?.stop()
            collectionView.isHidden = false
            return
        }

        collectionView.isHidden = true
        hlsContainer.isHidden = false
        hlsController?.streamURL = interactor?.hmsSDK?.room?.hlsStreamingState.variants.first?.url
        hlsController?.play()
    }

    private func observeBroadcast() {

        _ = NotificationCenter.default.addObserver(forName: Constants.joinedRoom,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            if let strongSelf = self {
                strongSelf.loadingIcon.hide()
                strongSelf.updateSettingsButton()
                strongSelf.updateHLSState()
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

            if let speaker = self?.viewModel?.speakers.first {
                self?.roomNameButton.setTitle(" 🔊 " + speaker.peer.name, for: .normal)
            } else {
                self?.roomNameButton.setTitle(self?.roomName, for: .normal)
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.toggleVideoTapped,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            if let video = notification.userInfo?["video"] as? HMSVideoTrack,
               video.trackId == self?.viewModel?.interactor?.hmsSDK?.localPeer?.videoTrack?.trackId {

                self?.publishVideoButton.isSelected = video.isMute()
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.toggleAudioTapped,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            if let audio = notification.userInfo?["audio"] as? HMSAudioTrack,
               audio.trackId == self?.viewModel?.interactor?.hmsSDK?.localPeer?.audioTrack?.trackId {

                self?.publishAudioButton.isSelected = audio.isMute()
            }
        }

        _ = NotificationCenter.default.addObserver(forName: Constants.roleUpdated, object: nil, queue: .main) { [weak self] _ in
            self?.updateSettingsButton()
            self?.updateHLSState()
        }

        _ = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.settingsButton.imageView?.rotate()
        }
    }

    private func setupButtonStates() {
        guard let localPeer = viewModel?.interactor?.hmsSDK?.localPeer else {
            return
        }

        if let videoTrack = localPeer.videoTrack as? HMSLocalVideoTrack {
            publishVideoButton.isSelected = videoTrack.isMute()
            publishVideoButton.isHidden = false
        } else {
            publishVideoButton.isHidden = true
        }

        if let audioTrack = localPeer.audioTrack as? HMSLocalAudioTrack {
            publishAudioButton.isSelected = audioTrack.isMute()
            publishAudioButton.isHidden = false
        } else {
            publishAudioButton.isHidden = true
        }
    }

    private func cleanup() {
        UIApplication.shared.isIdleTimerDisabled = false
        viewModel?.cleanup()
    }

    // MARK: - Settings Menu Button

    private func updateSettingsButton() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if #available(iOS 14.0, *) {
                self.settingsButton.menu = self.menu
                self.settingsButton.showsMenuAsPrimaryAction = true
            } else {
                // Fallback on earlier versions
            }

            self.settingsButton.setImage(self.settingsButtonIcon(), for: .normal)
            self.settingsButton.tintColor = self.settingsButtonTint()
        }
    }

    private func settingsButtonIcon() -> UIImage {
        var iconName = "gear"

        if interactor.isStreaming {
            iconName = "dot.radiowaves.left.and.right"
        } else if interactor.isRecording {
            iconName = "recordingtape"
        }

        return UIImage(systemName: iconName) ?? UIImage()
    }

    private func settingsButtonTint() -> UIColor {
        return interactor.isRecording ? UIColor.red : speakerButton.tintColor
    }

    private func menuItems() -> [UIAction] {

        let currentMode = viewModel?.mode ?? .regular

        let actions = [
            UIAction(title: "Audio Only Mode",
                     image: UIImage(systemName: "megaphone.fill"),
                     state: currentMode == .audioOnly ? .on : .off) { [weak self] _ in
                if currentMode != .audioOnly {
                    self?.viewModel?.mode = .audioOnly
                    self?.updateSettingsButton()
                }
            },
            UIAction(title: "Show Active Speakers",
                     image: UIImage(systemName: "person.3.fill"),
                     state: currentMode == .speakers ? .on : .off) { [weak self] (_) in
                if currentMode != .speakers {
                    self?.viewModel?.mode = .speakers
                    self?.updateSettingsButton()
                }
            },
            UIAction(title: "Video Only Mode",
                     image: UIImage(systemName: "video.fill.badge.checkmark"),
                     state: currentMode == .videoOnly ? .on : .off) { [weak self] (_) in
                if currentMode != .videoOnly {
                    self?.viewModel?.mode = .videoOnly
                    self?.updateSettingsButton()
                }
            },
            UIAction(title: "All Pinned Mode",
                     image: UIImage(systemName: "pin.circle.fill"),
                     state: currentMode == .pinned ? .on : .off) { [weak self] (_) in
                if currentMode != .pinned {
                    self?.viewModel?.mode = .pinned
                    self?.updateSettingsButton()
                }
            },
            UIAction(title: "Spotlight Mode",
                     image: UIImage(systemName: "figure.wave.circle.fill"),
                     state: currentMode == .spotlight ? .on : .off) { [weak self] _ in
                if currentMode != .spotlight {
                    self?.viewModel?.mode = .spotlight
                    self?.updateSettingsButton()
                }
            },
            UIAction(title: "Hero Mode",
                     image: UIImage(systemName: "shield.checkerboard"),
                     state: currentMode == .hero ? .on : .off) { [weak self] _ in
                if currentMode != .hero,
                   let remotePeers = self?.interactor.hmsSDK?.remotePeers?.count, remotePeers > 0 {
                    self?.viewModel?.mode = .hero
                    self?.updateSettingsButton()
                }
            },
            UIAction(title: "Default Mode",
                     image: UIImage(systemName: "rectangle.grid.2x2.fill"),
                     state: currentMode == .regular ? .on : .off) { [weak self] _ in
                if currentMode != .regular {
                    self?.viewModel?.mode = .regular
                    self?.updateSettingsButton()
                }
            },
            UIAction(title: "Change my name",
                     image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis")) { [weak self] _ in
                self?.showNamePrompt()
            }
        ]

        return actions
    }

    private func roleBasedActions() -> [UIAction] {

        var actions = [UIAction]()

        if interactor.canRemoteMute {
            let muteRolesAction = UIAction(title: "Remote Mute Role",
                                           image: UIImage(systemName: "speaker.slash.circle.fill")) { [weak self] _ in
                guard let self = self else { return }
                self.showMutePrompt()
            }
            actions.append(muteRolesAction)

            let muteAllAction = UIAction(title: "Remote Mute All",
                                         image: UIImage(systemName: "speaker.slash.fill")) { [weak self] _ in
                guard let self = self else { return }
                self.interactor.mute(role: nil)
            }
            actions.append(muteAllAction)
        }

        if interactor.canChangeRole {
            let changeAllRole = UIAction(title: "Change All Role To Role",
                                         image: UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill")) { [weak self] _ in
                guard let roles = self?.interactor.roles else { return }
                let changeAllRoleController = ChangeAllRoleViewController()
                changeAllRoleController.knownRoles = roles
                changeAllRoleController.delegate = self
                self?.navigationController?.pushViewController(changeAllRoleController, animated: true)
            }
            actions.append(changeAllRole)
        }

        let startRTMP = UIAction(title: "Start RTMP or Recording",
                                     image: UIImage(systemName: "record.circle")) { [weak self] _ in
            let rtmpSettingsController = RTMPSettingsViewController()
            rtmpSettingsController.delegate = self
            self?.navigationController?.pushViewController(rtmpSettingsController, animated: true)
        }
        actions.append(startRTMP)

        let stopRTMP = UIAction(title: "Stop RTMP and Recording",
                                     image: UIImage(systemName: "stop.circle")) { [weak self] _ in
            guard let self = self else { return }
            self.interactor?.hmsSDK?.stopRTMPAndRecording { [weak self] _, error in
                if let error = error {
                    self?.showActionError(error, action: "Stop RTMP/Recording")
                    return
                }
                self?.updateSettingsButton()
            }
        }
        actions.append(stopRTMP)

        let startHLS = UIAction(title: "Start HLS Streaming",
                                image: UIImage(systemName: "record.circle")) { [weak self] _ in
            let hlsSettingsController = HLSSettingsViewController()
            hlsSettingsController.delegate = self
            self?.navigationController?.pushViewController(hlsSettingsController, animated: true)
        }
        actions.append(startHLS)

        let stopHLS = UIAction(title: "Stop HLS Streaming",
                               image: UIImage(systemName: "stop.circle")) { [weak self] _ in
            guard let self = self else { return }
            self.interactor?.hmsSDK?.stopHLSStreaming { [weak self] _, error in
                if let error = error {
                    self?.showActionError(error, action: "Stop HLS")
                    return
                }
                self?.updateSettingsButton()
            }
        }
        actions.append(stopHLS)

        if interactor.canEndRoom {
            let endRoomAction = UIAction(title: "End Room",
                                         image: UIImage(systemName: "xmark.octagon.fill")) { [weak self] _ in
                guard let self = self else { return }
                
                self.interactor?.hmsSDK?.endRoom(reason: "Meeting Ended") { [weak self] _, error in
                    if let error = error {
                        self?.showActionError(error, action: "End Room")
                        return
                    }
                    self?.cleanup()
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
            actions.append(endRoomAction)

            let endRoomAndLockAction = UIAction(title: "End Room And Lock",
                                                image: UIImage(systemName: "lock.circle.fill")) { [weak self] _ in
                guard let self = self else { return }
                self.interactor?.hmsSDK?.endRoom(lock: true, reason: "Meeting Ended")
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { [weak self] in
                    self?.cleanup()
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
            actions.append(endRoomAndLockAction)
        }

        return actions
    }

    // MARK: - Role Change Interactors

    private func showRoleChangePrompt(for peer: HMSPeer, force: Bool) {

        dismissPresentedController { [weak self] in

            let title = force ? "Force Role Change for \(peer.name)" : "Request to Change Role for \(peer.name)"

            let alertController = UIAlertController(title: title,
                                                    message: "\n\n\n\n\n\n\n\n\n",
                                                    preferredStyle: .alert)

            let pickerView = UIPickerView(frame:
                CGRect(x: 0, y: 50, width: 270, height: 162))
            pickerView.dataSource = self
            pickerView.delegate = self

            alertController.view.addSubview(pickerView)

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alertController.addAction(UIAlertAction(title: "Send", style: .default) { [weak self, weak pickerView] _ in
                guard let rowIndex = pickerView?.selectedRow(inComponent: 0),
                      let targetRole = self?.interactor.roles?[rowIndex] else {
                    return
                }

                guard let currentRoleName = peer.role?.name, currentRoleName != targetRole.name else {
                    self?.showRoleIsSameError(for: peer, role: peer.role?.name ?? "")
                    return
                }

                self?.interactor?.changeRole(for: peer, to: targetRole, force: force)
            })

            self?.present(alertController, animated: true)
        }
    }

    private func showNamePrompt() {
        let title = "Change Name"
        let action = "Change"

        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Enter new name"
            textField.clearButtonMode = .always
            textField.text =  UserDefaults.standard.string(forKey: Constants.defaultName)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: action, style: .default) { [weak self] _ in
            guard let name = alertController.textFields?[0].text, !name.isEmpty else {
                return
            }

            self?.interactor.hmsSDK?.change(name: name, completion: { _, error in
                if let error = error {
                    self?.showActionError(error, action: "Change name")
                } else {
                    UserDefaults.standard.set(name, forKey: Constants.defaultName)
                }
            })
        })

        present(alertController, animated: true)
    }

    private func showMutePrompt() {

        dismissPresentedController { [weak self] in

            let title = "Remote Mute Role"

            let alertController = UIAlertController(title: title,
                                                    message: "\n\n\n\n\n\n\n\n\n",
                                                    preferredStyle: .alert)

            let pickerView = UIPickerView(frame:
                CGRect(x: 0, y: 50, width: 270, height: 162))
            pickerView.dataSource = self
            pickerView.delegate = self

            alertController.view.addSubview(pickerView)

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alertController.addAction(UIAlertAction(title: "Mute", style: .default) { [weak self, weak pickerView] _ in
                guard let rowIndex = pickerView?.selectedRow(inComponent: 0),
                      let targetRole = self?.interactor.roles?[rowIndex] else {
                    return
                }
                self?.interactor?.mute(role: targetRole)
            })

            self?.present(alertController, animated: true)
        }
    }

    private func dismissPresentedController(completion: @escaping () -> Void) {
        if self.presentedViewController != nil {
            self.dismiss(animated: true) {
                completion()
                return
            }
        }
        completion()
    }

    private func showRoleIsSameError(for peer: HMSPeer, role: String) {
        let title = "Error"

        let alertController = UIAlertController(title: title,
                                                message: "\(peer.name) is already a '\(role)'",
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        present(alertController, animated: true)
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
        alertController.addAction(UIAlertAction(title: "Preview", style: .default) { [weak self] _ in
            self?.showRolePreview(for: request)
        })

        present(alertController, animated: true)
    }

    private func showRolePreview(for request: HMSRoleChangeRequest) {
        guard let viewController = storyboard?.instantiateViewController(identifier: Constants.previewControllerIdentifier) as? RolePreviewViewController else {
            return
        }

        viewController.roleChangeRequest = request
        viewController.interactor = interactor

        navigationController?.pushViewController(viewController, animated: true)
    }

    private func handle(changeTrackState request: HMSChangeTrackStateRequest) {

        setupButtonStates()

        guard !request.mute else { return }

        dismiss(animated: true) { [weak self] in
            let title = "\(request.requestedBy?.name ?? "100ms app") is asking you to unmute \(request.track.kind == .video ? "video" : "audio")"

            let alertController = UIAlertController(title: title,
                                                    message: nil,
                                                    preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "Unmute", style: .default) { [weak self] _ in
                if request.track.kind == .video {
                    self?.viewModel?.switchVideo(isOn: true)
                } else {
                    self?.viewModel?.switchAudio(isOn: true)
                }

                self?.setupButtonStates()
            })
            alertController.addAction(UIAlertAction(title: "Ignore", style: .cancel))

            self?.present(alertController, animated: true)
        }
    }

    private func handle(removedFromRoom notification: HMSRemovedFromRoomNotification) {
        let title = "\(notification.requestedBy?.name ?? "100ms app") removed you from this room: \(notification.reason)"

        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            self?.cleanup()
            self?.navigationController?.popToRootViewController(animated: true)
        })

        present(alertController, animated: true)
    }

    // MARK: - Error Handlers

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

    private func showActionError(_ error: HMSError, action: String) {
        let title = "Could Not \(action)"

        let alertController = UIAlertController(title: title,
                                                message: error.message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        present(alertController, animated: true)
    }

    // MARK: - Button Action Handlers

    @IBAction private func roomNameTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.peersList, bundle: nil)
                .instantiateInitialViewController() as? PeersListViewController else {
            return
        }

        viewController.roomName = roomName

        viewController.meetingViewModel = viewModel
        viewController.speakers = viewModel?.speakers

        present(viewController, animated: true)
    }

    @IBAction private func muteRemoteStreamsTapped(_ sender: UIButton) {
        viewModel?.muteRemoteStreams(sender.isSelected)
        sender.isSelected = !sender.isSelected
    }

    @IBAction private func switchCameraTapped(_ sender: UIButton) {
        viewModel?.switchCamera()
    }

    @IBAction private func videoTapped(_ sender: UIButton) {
        guard viewModel?.mode != .audioOnly,
              let videoTrack = viewModel?.interactor?.hmsSDK?.localPeer?.videoTrack as? HMSLocalVideoTrack else {
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
        viewModel?.switchAudio(isOn: sender.isSelected)
        UserDefaults.standard.set(sender.isSelected, forKey: Constants.publishAudio)
        sender.isSelected = !sender.isSelected
    }

    @IBAction private func chatTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.chat, bundle: nil)
                .instantiateInitialViewController() as? ChatViewController else {
            return
        }

        viewController.interactor = viewModel?.interactor

        present(viewController, animated: true)
    }

    @IBAction func raiseHandTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let meta = PeerMetadata(isHandRaised: sender.isSelected)
        interactor?.hmsSDK?.change(metadataObject: meta) { [weak self] _, error in
            if let error = error {
                self?.showActionError(error, action: "Raise hand")
            }
        }
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
}

// MARK: - Picker View Delegates

extension MeetingViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        interactor.roles?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let role = interactor.roles?[row] else {
            return ""
        }

        return role.name
    }
}

extension MeetingViewController: ChangeAllRoleViewControllerDelegate {
    func changeAllRoleController(_ changeAllRoleController: ChangeAllRoleViewController, didSelect sourceRoles: [HMSRole]?, targetRole: HMSRole) {
        interactor?.hmsSDK?.changeRolesOfAllPeers(to: targetRole, limitToRoles: sourceRoles)
    }
}

extension MeetingViewController: RTMPSettingsViewControllerDelegate {
    func rtmpSettingsController(_ rtmpSettingsController: RTMPSettingsViewController, didSelect config: HMSRTMPConfig) {
        interactor?.hmsSDK?.startRTMPOrRecording(config: config) { [weak self] _, error in
            if let error = error {
                self?.showActionError(error, action: "Start RTMP/Recording")
                return
            }

            self?.updateSettingsButton()
        }
    }
}

extension MeetingViewController: HLSSettingsViewControllerDelegate {
    func hlsSettingsController(_ hlsSettingsController: HLSSettingsViewController, didSelect config: HMSHLSConfig) {
        interactor?.hmsSDK?.startHLSStreaming(config: config) { [weak self] _, error in
            if let error = error {
                self?.showActionError(error, action: "Start HLS Streaming")
                return
            }

            self?.updateSettingsButton()
        }
    }
}
