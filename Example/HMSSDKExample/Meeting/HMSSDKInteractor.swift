//
//  HMSInteractor.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSSDK

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
    internal var onMetadataUpdate: (() -> Void)?
    internal var updatedMuteStatus: ((HMSAudioTrack) -> Void)?
    internal var onNetworkQuality: (() -> Void)?
    internal var pipController = PiPController()

    // MARK: - Instance Properties

    internal var messages = [HMSMessage]()

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
            print(error.localizedDescription)
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
        
        RoomService.fetchToken(for: user, room) { [weak self] token in
            guard let token = token, let self = self else {
                print(#function, "Error fetching token")
                completion(nil)
                return
            }

            self.config = HMSConfig(userName: self.user, authToken: token, captureNetworkQualityInPreview: true)

            completion(self.config)
        }
    }
    
    func preview() {
        fetchConfig { [weak self] config in
            guard let config = config, let self = self else { return }
            self.hmsSDK?.preview(config: config, delegate: self)
        }
    }

    func join() {
        fetchConfig { [weak self] config in
            guard let config = config, let self = self else { return }
            self.hmsSDK?.join(config: config, delegate: self)
        }
    }

    func leave() {
        hmsSDK?.leave()
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

    func on(peer: HMSPeer, update: HMSPeerUpdate) {

        print(#function, peer.name, update.description)

        NotificationCenter.default.post(name: Constants.peersUpdated, object: nil, userInfo: ["peer": peer])

        switch update {
        case .peerJoined:
            Utilities.showToast(message: "🙌 \(peer.name) joined!")
        case .peerLeft:
            Utilities.showToast(message: "👋 \(peer.name) left!")
        case .roleUpdated:
            if let role = peer.role?.name {
                Utilities.showToast(message: "🎉 \(peer.name)'s role updated to \(role)")
                NotificationCenter.default.post(name: Constants.roleUpdated, object: nil)
            }
        case .networkQualityUpdated:
            onNetworkQuality?()
        default:
            print(#function, "Unhandled update type encountered")
        }
    }

    func on(track: HMSTrack, update: HMSTrackUpdate, for peer: HMSPeer) {
        print("#!", #function, peer.name, update.description, track.trackId, kindString(from: track.kind), track.source)
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

        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        let dateString = "\(hour):\(minutes):\(second)"

        print("Speaker update " + dateString, speakers.map { $0.peer.name },
              speakers.map { kindString(from: $0.track.kind) },
              speakers.map { $0.track.source })
        
        if let firstSpeaker = speakers.first {
            pipController.update(speaker: firstSpeaker)
        }
    }

    func on(room: HMSRoom, update: HMSRoomUpdate) {
        print(#function, room.name ?? "", update.description)

        switch update {
        case .browserRecordingStateUpdated, .rtmpStreamingStateUpdated, .hlsRecordingStateUpdated:
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
        print(#function, roleChangeRequest.requestedBy?.name ?? "100ms app", roleChangeRequest.suggestedRole.name)
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
}

// MARK: - Preview Listener

extension HMSSDKInteractor: HMSPreviewListener {
    func onPreview(room: HMSRoom, localTracks: [HMSTrack]) {
        print(#function, localTracks.map { $0.kind.rawValue }, localTracks.map { $0.source })
        onPreview?(room, localTracks)
    }
}

// MARK: - Logger

extension HMSSDKInteractor: HMSLogger {
    func log(_ message: String, _ level: HMSLogLevel) {
        guard level.rawValue <= HMSLogLevel.verbose.rawValue else { return }
        print(message)
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
