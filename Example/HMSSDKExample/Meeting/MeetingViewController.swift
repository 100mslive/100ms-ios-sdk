//
//  MeetingViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import HMSSDK
import MediaPlayer
import ReplayKit
import SwiftUI

final class MeetingViewController: UIViewController, UIDocumentPickerDelegate {

    // MARK: - View Properties

    var user: String {
        interactor.user
    }
    
    var roomName: String {
        interactor.room
    }
    
    internal var interactor: HMSSDKInteractor!

    @IBOutlet weak var hlsContainer: UIView!

    private var viewModel: MeetingViewModel?
    private var hlsController: HLSStreamViewController?
    
    private var isEarpieceOutputActivated = false

    @IBOutlet private weak var roomNameButton: UIButton! {
        didSet {
            roomNameButton.setTitle(roomName, for: .normal)
            roomNameButton.titleLabel?.lineBreakMode = .byTruncatingTail
            roomNameButton.titleLabel?.numberOfLines = 1
            roomNameButton.titleLabel?.adjustsFontSizeToFitWidth = false
        }
    }
    @IBOutlet weak var broadcasterPickerContainer: UIView!
    
    @IBOutlet private weak var speakerButton: UIButton!

    @IBOutlet private weak var collectionView: UICollectionView!

    @IBOutlet private weak var publishVideoButton: UIButton!
    @IBOutlet private weak var publishAudioButton: UIButton!
    @IBOutlet private weak var handRaiseButton: UIButton!

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
    @IBOutlet weak var viewPollView: UIView!
    
    @IBAction func viewPollTapped(_ sender: Any) {
        showPoll()
    }
    
    
    
    private var menu: UIMenu {
        UIMenu(children: menuItems() + roleBasedActions())
    }

    // MARK: - View Lifecycle

    func setupHLSController() {
        let vc = HLSStreamViewController()
        vc.hmsSDK = interactor.hmsSDK
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
        
        prepareSystemBroadcaster()
        broadcasterPickerContainer.isHidden = !interactor.canScreenShare

        UIApplication.shared.isIdleTimerDisabled = true

        viewModel = MeetingViewModel(self.user, self.roomName, collectionView, interactor: interactor)
        
        viewModel?.delegate = self
        setupViewPollToastState()
        
        interactor.pipController.setup(with: self.collectionView)

        setupButtonStates()

        handleError()
        observeBroadcast()

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
            self?.updateSettingsButton()
        }
        
        interactor.onPoll = { [weak self] poll in
            self?.setupViewPollToastState()
        }
        
        interactor.onHandRaiseUpdate = { [weak self] in
            self?.setupButtonStates()
        }

        viewModel?.updateLocalPeerTracks = { [weak self] in
            self?.setupButtonStates()
        }

        viewModel?.showRoleChangePrompt = { [weak self] peer, force in
            self?.showRoleChangePrompt(for: peer, force: force)
        }
        
        interactor.join()
        
        musicButton.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
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

    var playingExternally = false
    func updateHLSState() {
        guard interactor?.hmsSDK?.localPeer?.role?.name.hasPrefix("hls-") ?? false else {
            hlsContainer.isHidden = true
            hlsController?.stop()
            collectionView.isHidden = false
            if playingExternally {
                interactor.hmsSDK?.resumeAfterExternalAudioPlayback()
                playingExternally = false
            }
            return
        }

        collectionView.isHidden = true
        hlsContainer.isHidden = false
        interactor.hmsSDK?.prepareForExternalAudioPlayback()
        playingExternally = true
        if let streamUrl = interactor?.hmsSDK?.room?.hlsStreamingState.variants.first?.url {
            
            if hlsController == nil {
                setupHLSController()
            }
            
            hlsController?.play(url: streamUrl)
        }
        else {
            hlsController?.stop()
        }
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
        
        handRaiseButton.isSelected = localPeer.isHandRaised
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
            
            self.broadcasterPickerContainer.isHidden = !self.interactor.canScreenShare
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
    
    func presentSheet(with image: UIImage) {
        let imagePreviewController = UIHostingController(rootView: ImagePreviewView(image: image))
        imagePreviewController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        self.present(imagePreviewController, animated: true, completion: nil)
    }
    
    func showTicTacToe() {
        guard let store = interactor?.sessionStore else { return }
        let model = TicTacToeModel(store: store)
        let gameController = UIHostingController(rootView: TicTacToeView(model: model))
        gameController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        self.present(gameController, animated: true, completion: nil)
    }

    func presentAlert(with title: String, message: String) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        self.present(alertController, animated: true)
    }

    private func menuItems() -> [UIAction] {

        let currentMode = viewModel?.mode ?? .regular
        
        let isVBActivated = UserDefaults.standard.bool(forKey: "virtualBackgroundPluginEnabled")
        
        let isLocalAudioFilePlaybackEnabled = AudioSourceType(rawValue: UserDefaults.standard.integer(forKey: Constants.defaultAudioSource)) == .audioMixer

        var actions = [
            UIAction(title: "Show new peer list",
                     image: UIImage(systemName: "megaphone.fill")) { [weak self] _ in
                         self?.showNewPeerList()
            },
            
            UIAction(title: "Audio Only Mode",
                     image: UIImage(systemName: "megaphone.fill"),
                     state: currentMode == .audioOnly ? .on : .off) { [weak self] _ in
                if currentMode != .audioOnly {
                    self?.viewModel?.mode = .audioOnly
                    self?.updateSettingsButton()
                }
            },
            UIAction(title: "Switch to Earpiece",
                     image: UIImage(systemName: "ear.fill"),
                     state: self.isEarpieceOutputActivated ? .on : .off) { [weak self] _ in
                         
                guard let self = self else { return }
                         
                if self.isEarpieceOutputActivated {
                     try? self.interactor.hmsSDK?.switchAudioOutput(to: HMSAudioOutputDevice.speaker)
                     self.isEarpieceOutputActivated = false
                 }
                 else {
                     try? self.interactor.hmsSDK?.switchAudioOutput(to: HMSAudioOutputDevice.earpiece)
                     self.isEarpieceOutputActivated = true
                 }
                 self.updateSettingsButton()
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
            
            UIAction(title: "Capture current frame",
                     image: UIImage(systemName: "camera.circle.fill")) { [weak self] _ in
                        
                 if let image = self?.interactor.frameCapturePlugin?.capture() {
                     
                     let imagePreviewController = UIHostingController(rootView: ImagePreviewView(image: image))
                     imagePreviewController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
                     self?.present(imagePreviewController, animated: true, completion: nil)
                 }
            },

            UIAction(title: "Enable virtual background",
                     image: UIImage(systemName: "person.crop.rectangle.fill"),
                     state: isVBActivated ? .on : .off) { [weak self] _ in
                 if isVBActivated {
                     self?.interactor.virtualBackgroundPlugin?.deactivate()
                     UserDefaults.standard.set(false, forKey: "virtualBackgroundPluginEnabled")
                 }
                 else {
                     _ = self?.interactor.virtualBackgroundPlugin?.activate()
                     UserDefaults.standard.set(true, forKey: "virtualBackgroundPluginEnabled")
                 }
                 self?.updateSettingsButton()
            },
            
            UIAction(title: "Change my name",
                     image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis")) { [weak self] _ in
                self?.showNamePrompt()
            }
        ]
        
        if interactor?.sessionStore != nil {
            actions.append(UIAction(title: "Play TicTacToe",
                     image: UIImage(systemName: "gamecontroller")) { [weak self] _ in
                self?.showTicTacToe()
            })
        }
        
        if isLocalAudioFilePlaybackEnabled {
            actions.append(contentsOf: [UIAction(title: "Play Audio",
                                                 image: UIImage(systemName: "music.note")) { [weak self] _ in
                
                let pickerController = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
                pickerController.delegate = self
                pickerController.modalPresentationStyle = .automatic
                pickerController.allowsMultipleSelection = true
                self?.present(pickerController, animated: true, completion: nil)
                
                self?.updateSettingsButton()
            },
                                        
                                        UIAction(title: "Stop Audio",
                                                 image: UIImage(systemName: "stop.circle.fill")) { [weak self] _ in
                
                self?.interactor.audioFilePlayerNode.stop()
                self?.musicButton.isHidden = true
                
                self?.updateSettingsButton()
            }])
        }
        
        if interactor.canScreenShare {
            
            actions.append(contentsOf: [
            
                UIAction(title: "Start Streaming in-app content",
                         image: UIImage(systemName: "rectangle.dashed.badge.record")) { [weak self] _ in
                            
                             self?.interactor.hmsSDK?.startAppScreenCapture() { error in
                                 if error != nil {
                                     // to spot any scenario of errors

                                     let alertController = UIAlertController(title: "ScreenShare",
                                                                             message: error?.localizedDescription,
                                                                             preferredStyle: .alert)


                                     alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

                                     self?.present(alertController, animated: true)
                                 }
                             }
                },
                
                UIAction(title: "Stop Streaming in-app content",
                         image: UIImage(systemName: "rectangle.dashed.badge.record")) { [weak self] _ in
                            
                             self?.interactor.hmsSDK?.stopAppScreenCapture()
                },
            ])
            
        }

        return actions
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        urls.forEach {
            do {
                try interactor.audioFilePlayerNode.play(fileUrl: $0)
                musicButton.isHidden = false
            }
            catch {
                print(error)
            }
        }
    }

    private func roleBasedActions() -> [UIAction] {

        var actions = [UIAction]()
        
        
        let roomState = UIAction(title: "Room State",
                                image: UIImage(systemName: "doc.circle")) { [weak self] _ in
            let roomStateController = RoomStateViewController()
            roomStateController.room = self?.interactor?.hmsSDK?.room
            self?.navigationController?.pushViewController(roomStateController, animated: true)
        }
        actions.append(roomState)
        

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
        
        if interactor.canWritePolls {
            let createPoll = UIAction(title: "Create Poll",
                                      image: UIImage(systemName: "book")) { [weak self] _ in
                self?.showPollCreate()
            }
            actions.append(createPoll)
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
                if let error = error as? HMSError {
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
                if let error = error as? HMSError {
                    self?.showActionError(error, action: "Stop HLS")
                    return
                }
                self?.updateSettingsButton()
            }
        }
        actions.append(stopHLS)
        
        let sendMetadata = UIAction(title: "Send HLS Timed Metadata",
                               image: UIImage(systemName: "tray.and.arrow.up.fill")) { [weak self] _ in
            guard let self = self else { return }
            self.showMetadataPrompt()
        }
        actions.append(sendMetadata)

        if interactor.canEndRoom {
            let endRoomAction = UIAction(title: "End Room",
                                         image: UIImage(systemName: "xmark.octagon.fill")) { [weak self] _ in
                guard let self = self else { return }
                
                self.interactor?.hmsSDK?.endRoom(reason: "Meeting Ended") { [weak self] _, error in
                    if let error = error as? HMSError {
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
                if let error = error as? HMSError {
                    self?.showActionError(error, action: "Change name")
                } else {
                    UserDefaults.standard.set(name, forKey: Constants.defaultName)
                }
            })
        })

        present(alertController, animated: true)
    }
    
    private func showMetadataPrompt() {
        let title = "Enter metadata to send"
        let action = "Send"

        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.clearButtonMode = .always
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: action, style: .default) { [weak self] _ in
            guard let metadataPayload = alertController.textFields?[0].text, !metadataPayload.isEmpty else {
                return
            }
            
            let metadata = HMSHLSTimedMetadata(payload: metadataPayload, duration: 5)

            self?.interactor.hmsSDK?.sendHLSTimedMetadata([metadata], completion: { _, error in
                if let error = error as? HMSError {
                    self?.showActionError(error, action: "Send Metadata")
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
        
        interactor.pipController.roomEnded(reason: title)

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
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        present(alertController, animated: true)
    }
    
    func prepareSystemBroadcaster() {
        let frame = CGRect(x: 0, y:0, width: 44, height: 44)
        let systemBroadcastPicker = RPSystemBroadcastPickerView(frame: frame)
        systemBroadcastPicker.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        systemBroadcastPicker.preferredExtension = "live.100ms.videoapp.screenshare"
        systemBroadcastPicker.showsMicrophoneButton = false
        
        for view in systemBroadcastPicker.subviews {
            if let button = view as? UIButton {
                
                let configuration = UIImage.SymbolConfiguration(pointSize: 24)
                let image = UIImage(systemName: "rectangle.on.rectangle", withConfiguration: configuration)?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
                button.setImage(image, for: .normal)
            }
        }
        
        broadcasterPickerContainer.addSubview(systemBroadcastPicker)
    }

    // MARK: - Button Action Handlers

    @IBOutlet weak var musicButton: UIButton!
    @IBAction func musicTapped(_ sender: UIButton) {
        let player = interactor.audioFilePlayerNode
        
        let musicController = UIHostingController(rootView: MusicControlView(player: player))
        musicController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        musicController.modalTransitionStyle = .crossDissolve
        musicController.view.backgroundColor = .clear
        self.present(musicController, animated: true, completion: nil)
    }
    
    @IBAction func showPollCreate() {
        guard let center = interactor?.hmsSDK?.interactivityCenter, let role = interactor?.hmsSDK?.localPeer?.role else { return }
        let pollAdminRoles = interactor?.roles?.filter({ $0.name == "host" || $0.name == "teacher" }) ?? []
        let model = PollCreateModel(interactivityCenter: center, limitViewResultsToRoles: pollAdminRoles, currentRole: role)
        model.onPollStart = { [weak self] in
            self?.setupViewPollToastState()
            self?.dismiss(animated: true)
        }

        let pollController = UIHostingController(rootView: PollCreateView(model: model))
        pollController.view.backgroundColor = .red
        self.present(pollController, animated: true, completion: nil)
    }
    
    func showPoll() {
        guard let center = interactor?.hmsSDK?.interactivityCenter, let poll = interactor?.hmsSDK?.interactivityCenter.polls.last(where: { $0.state == .started }), let role = interactor?.hmsSDK?.localPeer?.role else { return }
        let model = PollVoteViewModel(poll: poll, interactivityCenter: center, currentRole: role, peerList: interactor?.hmsSDK?.room?.peers ?? [])
        let pollController = UIHostingController(rootView: PollVoteView(model: model))
        pollController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        self.present(pollController, animated: true, completion: nil)
    }
    
    func setupViewPollToastState() {
        let hasLivePolls = interactor?.hmsSDK?.interactivityCenter.polls.first(where: { $0.state == .started }) != nil
        viewPollView.isHidden = !hasLivePolls
    }
    
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
    
    func showNewPeerList() {
        guard let viewController = UIStoryboard(name: Constants.peersList, bundle: nil)
                .instantiateViewController(identifier: Constants.paginatedPeersList) as? PaginatedPeersListViewController else {
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
        sender.isSelected = !sender.isSelected
        NotificationCenter.default.post(name: Constants.updateVideoCellButton,
                                        object: nil,
                                        userInfo: ["video": videoTrack])
    }

    @IBAction private func micTapped(_ sender: UIButton) {
        viewModel?.switchAudio(isOn: sender.isSelected)
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
        
        if sender.isSelected {
            interactor?.hmsSDK?.raiseLocalPeerHand() { [weak self] _, error in
                if let error = error as? HMSError {
                    self?.showActionError(error, action: "Raise hand")
                }
            }
        } else {
            interactor?.hmsSDK?.lowerLocalPeerHand() { [weak self] _, error in
                if let error = error as? HMSError {
                    self?.showActionError(error, action: "Raise hand")
                }
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
            if let error = error as? HMSError {
                self?.showActionError(error, action: "Start RTMP/Recording")
                return
            }

            self?.updateSettingsButton()
        }
    }
}

extension MeetingViewController: HLSSettingsViewControllerDelegate {
    func hlsSettingsController(_ hlsSettingsController: HLSSettingsViewController, didSelect config: HMSHLSConfig?) {
        interactor?.hmsSDK?.startHLSStreaming(config: config) { [weak self] _, error in
            if let error = error as? HMSError {
                self?.showActionError(error, action: "Start HLS Streaming")
                return
            }

            self?.updateSettingsButton()
        }
    }
}
