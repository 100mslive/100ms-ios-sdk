//
//  HMSInteractor.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSSDK
import HMSAnalyticsSDK
import SwiftyBeaver

final class HMSSDKInteractor: HMSUpdateListener {

    private(set) var hmsSDK: HMSSDK?
    let user: String
    let room: String

    internal var onPreview: ((HMSRoom, [HMSTrack]) -> Void)?
    internal var onRoleChange: ((HMSRoleChangeRequest) -> Void)?
    internal var onChangeTrackState: ((HMSChangeTrackStateRequest) -> Void)?
    internal var onRemovedFromRoom: ((HMSRemovedFromRoomNotification) -> Void)?
    internal var onRecordingUpdate: (() -> Void)?
    internal var onHLSUpdate: (() -> Void)?
    internal var onHandRaiseUpdate: (() -> Void)?
    internal var onMetadataUpdate: (() -> Void)?
    internal var updatedMuteStatus: ((HMSAudioTrack) -> Void)?
    internal var onNetworkQuality: (() -> Void)?
    internal var pipController = PiPController()
    internal var previousRole: HMSRole?
    
    let log = SwiftyBeaver.self

    internal var sessionStore: HMSSessionStore?
    internal var onSpotlight: ((String?) -> Void)?
    private static let spotlightKey = "spotlight"
    private static let pinnedMessageKey = "pinnedMessage"

    // MARK: - Instance Properties

    internal var messages = [HMSMessage]()
    internal var onPinnedMessage: (() -> Void)?
    internal var pinnedMessage: String? {
        didSet {
            onPinnedMessage?()
        }
    }
    
    internal var onPoll: ((HMSPoll) -> Void)?

    internal var isRecording: Bool {
        get {
            guard let room = hmsSDK?.room else { return false }
            return room.browserRecordingState.running || room.serverRecordingState.running || room.hlsRecordingState.running
        }
    }

    internal var isStreaming: Bool {
        get {
            guard let room = hmsSDK?.room else { return false }
            return room.rtmpStreamingState.running || room.hlsStreamingState.running
        }
    }

    private var config: HMSConfig?
    
    private var videoPlugins = [HMSVideoPlugin]()
    var virtualBackgroundPlugin: HMSVideoPlugin?
    var frameCapturePlugin: HMSFrameCapturePlugin?

    // MARK: - Setup SDK

    init(for user: String,
         in room: String) {
        self.user = user
        self.room = room
        setupPlugins()
        setupSDK()
    }
    
    var audioMixerSource: HMSAudioMixerSource?
    let audioFilePlayerNode = HMSAudioFilePlayerNode()
    
    
    
    private func setupSDK() {
        hmsSDK = HMSSDK.build { sdk in
            sdk.appGroup = "group.live.100ms.videoapp"
            
            sdk.trackSettings = HMSTrackSettings.build { videoSettingsBuilder, audioSettingsBuilder in
                videoSettingsBuilder.initialMuteState = UserDefaults.standard.publishVideo ? .unmute : .mute
                videoSettingsBuilder.videoPlugins = self.videoPlugins
                videoSettingsBuilder.cameraFocusMode = .focusModeTapToAutoFocus
                videoSettingsBuilder.cameraFacing = UserDefaults.standard.useBackCamera ? .back : .front
                
                if UserDefaults.standard.bool(forKey: Constants.enableOrientationLock) {
                    videoSettingsBuilder.cameraOrientationLock = .landscape
                }
                
                audioSettingsBuilder.initialMuteState = UserDefaults.standard.publishAudio ? .unmute : .mute
                audioSettingsBuilder.audioSource = self.audioSource(for: sdk)
                
                if UserDefaults.standard.bool(forKey: Constants.musicMode) {
                    audioSettingsBuilder.audioMode = .music
                }
            }
            
            sdk.logger = self
        }
    }
    
    private func audioSource(for sdk: HMSSDK) -> HMSAudioSource? {
        
        let isLocalAudioFilePlaybackEnabled = AudioSourceType(rawValue: UserDefaults.standard.integer(forKey: Constants.defaultAudioSource)) == .audioMixer
        
        guard isLocalAudioFilePlaybackEnabled else { return nil }
        
        do {
            self.audioFilePlayerNode.volume = 0.5
            let nodes = [self.audioFilePlayerNode, HMSMicNode(), try sdk.screenBroadcastAudioReceiverNode()]
            
            self.audioMixerSource = try HMSAudioMixerSource(nodes: nodes)
        }
        catch {
            log.error("Error creating audio source: \(error.localizedDescription)")
        }
        
        return self.audioMixerSource
    }
    
    private func setupPlugins() {
        if #available(iOS 15.0, *) {
            
            virtualBackgroundPlugin = HMSVirtualBackgroundPlugin(backgroundImage: UIImage(named: "VB1"))
            
            if UserDefaults.standard.bool(forKey: "virtualBackgroundPluginEnabled") == true {
                virtualBackgroundPlugin?.activate()
            }
            
            if let virtualBackgroundPlugin = virtualBackgroundPlugin {
                videoPlugins.append(virtualBackgroundPlugin)
            }
            
            // HMSFrameCapturePlugin allows you to capture current local video frame
            frameCapturePlugin = HMSFrameCapturePlugin()
            frameCapturePlugin?.activate()
            videoPlugins.append(frameCapturePlugin!)
        }
        
        // Adding custom plugin below for demonstration purposes.
        // It is disabled and not used in the sample code.
        
        // Add our custom grayscale plugin - deactivated
        let grayScalePlugin = GrayscaleVideoPlugin()
        grayScalePlugin.deactivate()
        videoPlugins.append(grayScalePlugin)
    }

    private func setup(for user: String, token: String, _ room: String) {
        guard let config = config else { return }
        hmsSDK?.join(config: config, delegate: self)
    }
    
    func fetchConfig(completion: @escaping ((HMSConfig?) -> Void)) {
        guard config == nil else {
            completion(config)
            return
        }
        
        if room.filter({$0 == "-"}).count == 2 {
            
        
            hmsSDK?.getAuthTokenByRoomCode(room, userID: user) { [weak self] token, error in
                guard let token = token, let self = self else {
                    self?.log.error("Error fetching token: \(error?.localizedDescription ?? "unknown")")
                    completion(nil)
                    NotificationCenter.default.post(name: Constants.gotError,
                                                    object: nil,
                                                    userInfo: ["error": "\(error?.localizedDescription ?? "Error fetching token")"])
                    return
                }

                self.config = HMSConfig(userName: self.user, authToken: token, captureNetworkQualityInPreview: true)

                completion(self.config)
            }
        }
        else {
            NotificationCenter.default.post(name: Constants.gotError,
                                            object: nil,
                                            userInfo: ["error": "Not a room code, pls enter a valid room code."])
        }
    }
    
    func preview() {
        fetchConfig { [weak self] config in
            guard let config = config, let self = self else { return }
            self.hmsSDK?.preview(config: config, delegate: self)
        }
    }

    func join() {
        hmsSDK?.interactivityCenter.addPollUpdateListner { [weak self] poll, update in
            switch update {
            case .started:
                self?.onPoll?(poll)
            case .resultsUpdated:
                self?.onPollResults?(poll)
            case .stopped:
                self?.onPoll?(poll)
                break
            @unknown default:
                break
            }
        }
        
        fetchConfig { [weak self] config in
            guard let config = config, let self = self else { return }
            self.previousRole = hmsSDK?.localPeer?.role
            self.hmsSDK?.join(config: config, delegate: self)
        }
    }
    
    func leave() {
        hmsSDK?.leave()
    }
    
    func setSpotlight(trackId: String?) {
        guard let sessionStore = sessionStore else { return }
        
        sessionStore.set(trackId ?? "", forKey: HMSSDKInteractor.spotlightKey)
    }
    
    func setPinnedMessage(_ text: String?, completion: @escaping ((Any?, Error?) -> Void)) {
        guard let sessionStore = sessionStore else { return }
        sessionStore.set(text ?? "", forKey: HMSSDKInteractor.pinnedMessageKey, completion: completion)
    }

    // MARK: - HMSSDK Listener Callbacks

    func on(join room: HMSRoom) {
        if let peer = room.peers.first {
            NotificationCenter.default.post(name: Constants.joinedRoom, object: nil, userInfo: ["peer": peer])
        }
        
        if let videoTrack = hmsSDK?.localPeer?.videoTrack {
            pipController.update(track: videoTrack, name: hmsSDK?.localPeer?.name)
        }
    }
    
    func onPeerListUpdate(added: [HMSPeer], removed: [HMSPeer]) {
        added.forEach {
            NotificationCenter.default.post(name: Constants.peersUpdated, object: nil, userInfo: ["peer": $0])
        }
        removed.forEach {
            NotificationCenter.default.post(name: Constants.peersUpdated, object: nil, userInfo: ["peer": $0])
        }
    }

    func on(peer: HMSPeer, update: HMSPeerUpdate) {

        log.verbose(#function, peer.name, update.description)

        NotificationCenter.default.post(name: Constants.peersUpdated, object: nil, userInfo: ["peer": peer])

        switch update {
        case .peerJoined:
            if !peer.isLocal {
                Utilities.showToast(message: "🙌 \(peer.name) joined!")
            }
        case .peerLeft:
            Utilities.showToast(message: "👋 \(peer.name) left!")
        case .roleUpdated:
            if peer.isLocal && previousRole == nil {
                previousRole = peer.role
                return
            }
            
            if let role = peer.role?.name {
                Utilities.showToast(message: "🎉 \(peer.name)'s role updated to \(role)")
                NotificationCenter.default.post(name: Constants.roleUpdated, object: nil)
            }
        case .networkQualityUpdated:
            onNetworkQuality?()
        case .handRaiseUpdated:
            if peer.isLocal {
                onHandRaiseUpdate?()
            }
        default:
            log.verbose(#function, "Unhandled update type encountered")
        }
    }

    func on(track: HMSTrack, update: HMSTrackUpdate, for peer: HMSPeer) {
        log.verbose(#function, context: [peer.name, update.description, track.trackId, kindString(from: track.kind), track.source])
        
        if let audio = track as? HMSAudioTrack {
            updatedMuteStatus?(audio)
        }
        if let videoTrack = track as? HMSRemoteVideoTrack, videoTrack.source == HMSCommonTrackSource.screen {
            if update == .trackAdded {
                pipController.set(screenTrack: videoTrack)
            }
            else if update == .trackRemoved {
                pipController.remove(screenTrack: videoTrack)
            }
        }
    }

    func on(error: Error) {
        guard let error = error as? HMSError else { return }
        NotificationCenter.default.post(name: Constants.gotError,
                                        object: nil,
                                        userInfo: ["error": "\(error.localizedDescription)"])
    }

    func on(message: HMSMessage) {
        switch message.type {
        case "chat":
            messages.append(message)
            NotificationCenter.default.post(name: Constants.messageReceived, object: nil)
            Utilities.showToast(message: "💬 \(message.sender?.name ?? "Unknown sender") sent you a message")
        case "metadata":
            NotificationCenter.default.post(name: Constants.sessionMetadataReceived, object: nil)
        default:
            break
        }
    }

    func on(updated speakers: [HMSSpeaker]) {
        speakers.first.map(pipController.update)
    }

    func on(room: HMSRoom, update: HMSRoomUpdate) {
        log.verbose(#function, room.name ?? "", update.description)

        switch update {
        case .browserRecordingStateUpdated, .rtmpStreamingStateUpdated, .hlsRecordingStateUpdated:
            if room.browserRecordingState.initialising {
                Utilities.showToast(message: "Recording is preparing to start")
            }
            onRecordingUpdate?()
        case .hlsStreamingStateUpdated:
            onHLSUpdate?()
        case .metaDataUpdated:
            onMetadataUpdate?()
        default:
            break
        }

    }

    func on(roleChangeRequest: HMSRoleChangeRequest) {
        log.verbose(#function, roleChangeRequest.requestedBy?.name ?? "100ms app", roleChangeRequest.suggestedRole.name)
        onRoleChange?(roleChangeRequest)
    }

    func onReconnecting() {
        Utilities.showToast(message: "Trying to Reconnect")
    }

    func onReconnected() {
        Utilities.showToast(message: "Reconnection Successful")
    }

    func on(changeTrackStateRequest: HMSChangeTrackStateRequest) {
        onChangeTrackState?(changeTrackStateRequest)
    }

    func on(removedFromRoom notification: HMSRemovedFromRoomNotification) {
        onRemovedFromRoom?(notification)
    }

    func on(remoteAudioStats: HMSRemoteAudioStats, track: HMSAudioTrack, peer: HMSPeer) {
        NotificationCenter.default.post(name: Constants.trackStatsUpdated, object: peer, userInfo: ["stats": remoteAudioStats, "track": track, "peer": peer])
    }

    func on(remoteVideoStats: HMSRemoteVideoStats, track: HMSVideoTrack, peer: HMSPeer) {
        NotificationCenter.default.post(name: Constants.trackStatsUpdated, object: peer, userInfo: ["stats": remoteVideoStats, "track": track, "peer": peer])
    }

    func on(localAudioStats: HMSLocalAudioStats, track: HMSAudioTrack, peer: HMSPeer) {
        NotificationCenter.default.post(name: Constants.trackStatsUpdated, object: peer, userInfo: ["stats": localAudioStats, "track": track, "peer": peer])
    }

    func on(localVideoStats: [HMSLocalVideoStats], track: HMSVideoTrack, peer: HMSPeer) {
        NotificationCenter.default.post(name: Constants.trackStatsUpdated, object: peer, userInfo: ["stats": localVideoStats, "track": track, "peer": peer])
    }
    
    func on(sessionStoreAvailable store: HMSSessionStore) {
        sessionStore = store
        store.observeChanges(forKeys: [HMSSDKInteractor.spotlightKey, HMSSDKInteractor.pinnedMessageKey]) { [weak self] key, value in
            switch key {
            case HMSSDKInteractor.spotlightKey:
                self?.onSpotlight?(value as? String)
            case HMSSDKInteractor.pinnedMessageKey:
                self?.pinnedMessage = value as? String
            default:
                break
                
            }
        }
    }
    
    var onPollResults:((HMSPoll)->Void)?
    
    // MARK: - Role Actions

    internal func changeRole(for peer: HMSPeer, to role: HMSRole, force: Bool = false) {
        hmsSDK?.changeRole(for: peer, to: role, force: force)
    }

    internal func accept(changeRole request: HMSRoleChangeRequest) {
        hmsSDK?.accept(changeRole: request)
    }

    internal func mute(role: HMSRole?) {
        var roleFilter: [HMSRole]?
        if let role = role {
            roleFilter = [role]
        }
        hmsSDK?.changeTrackState(mute: true, for: .audio, roles: roleFilter)
    }

    // MARK: - Role Info

    internal var roles: [HMSRole]? {
        hmsSDK?.roles
    }

    internal var canChangeRole: Bool {
        hmsSDK?.localPeer?.role?.permissions.changeRole ?? false
    }

    internal var canRemoteMute: Bool {
        hmsSDK?.localPeer?.role?.permissions.mute ?? false
    }

    internal var canRemovePeer: Bool {
        hmsSDK?.localPeer?.role?.permissions.removeOthers ?? false
    }

    internal var canEndRoom: Bool {
        hmsSDK?.localPeer?.role?.permissions.endRoom ?? false
    }
    
    internal var canScreenShare: Bool {
        hmsSDK?.localPeer?.role?.publishSettings.allowed?.contains("screen") ?? false
    }
    
    internal var canWritePolls: Bool {
        hmsSDK?.localPeer?.role?.permissions.pollWrite ?? false
    }
}

// MARK: - Preview Listener

extension HMSSDKInteractor: HMSPreviewListener {
    func onPreview(room: HMSRoom, localTracks: [HMSTrack]) {
        log.verbose(#function, context: [localTracks.map { $0.kind.rawValue }, localTracks.map { $0.source }])
        onPreview?(room, localTracks)
    }
}

// MARK: - Logger

extension HMSSDKInteractor: HMSLogger {
    func log(_ message: String, _ level: HMSLogLevel) {
        switch level {
        case .error:
            log.error(message)
        case .warning:
            log.warning(message)
        case .verbose:
            log.verbose(message)
        default:
            break
        }
    }
}

// MARK: - Enums to String Converter

extension HMSSDKInteractor {
    func kindString(from kind: HMSTrackKind) -> String {
        switch kind {
        case .audio:
            return "Audio"
        case .video:
            return "Video"
        default:
            return "Unknown Kind"
        }
    }
}
