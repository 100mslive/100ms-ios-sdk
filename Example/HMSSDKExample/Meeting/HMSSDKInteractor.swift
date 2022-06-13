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

    // MARK: - Setup SDK

    init(for user: String,
         in room: String) {
        self.user = user
        self.room = room
        setupSDK()
    }
    
    private func setupSDK() {
        hmsSDK = HMSSDK.build { sdk in
            let videoSettings = HMSVideoTrackSettings(codec: .VP8,
                                                          resolution: .init(width: 320, height: 180),
                                                          maxBitrate: 512,
                                                          maxFrameRate: 25,
                                                          cameraFacing: .front,
                                                      trackDescription: "Just a normal video track")
            
            let audioSettings = HMSAudioTrackSettings(maxBitrate: 32, trackDescription: "Just a normal audio track")
            sdk.trackSettings = HMSTrackSettings(videoSettings: videoSettings, audioSettings: audioSettings)
            sdk.logger = self
        }
    }

    func fetchConfig(completion: @escaping ((HMSConfig?) -> Void)) {
        if let config = config {
            completion(config)
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
    }

    func on(error: HMSError) {
        NotificationCenter.default.post(name: Constants.gotError,
                                        object: nil,
                                        userInfo: ["error": error.message])
    }

    func on(message: HMSMessage) {

        messages.append(message)
        NotificationCenter.default.post(name: Constants.messageReceived, object: nil)
        Utilities.showToast(message: "💬 \(message.sender!.name) sent you a message")
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

    func on(remoteAudioStats: HMSRemoteAudioStats, track: HMSRemoteAudioTrack, peer: HMSPeer) {
        NotificationCenter.default.post(name: Constants.trackStatsUpdated, object: peer, userInfo: ["stats": remoteAudioStats, "track": track, "peer": peer])
    }

    func on(remoteVideoStats: HMSRemoteVideoStats, track: HMSRemoteVideoTrack, peer: HMSPeer) {
        NotificationCenter.default.post(name: Constants.trackStatsUpdated, object: peer, userInfo: ["stats": remoteVideoStats, "track": track, "peer": peer])
    }

    func on(localAudioStats: HMSLocalAudioStats, track: HMSLocalAudioTrack, peer: HMSPeer) {
        NotificationCenter.default.post(name: Constants.trackStatsUpdated, object: peer, userInfo: ["stats": localAudioStats, "track": track, "peer": peer])
    }

    func on(localVideoStats: HMSLocalVideoStats, track: HMSLocalVideoTrack, peer: HMSPeer) {
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
