//
//  HMSInteractor.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSSDK

final class HMSSDKInteractor: HMSUpdateListener {

    internal var hmsSDK: HMSSDK?
    internal var onPreview: ((HMSRoom, [HMSTrack]) -> Void)?
    internal var onRoleChange: ((HMSRoleChangeRequest) -> Void)?
    
    // MARK: - Instance Properties

    internal var messages = [HMSMessage]()
    
    private var config: HMSConfig?

    // MARK: - Setup Stream

    init(for user: String,
         in room: String,
         _ completion: @escaping () -> Void) {

        RoomService.setup(for: user, room) { [weak self] token, aRoom in
            guard let token = token else {
                print(#function, "Error fetching token")
                return
            }

            self?.setup(for: user, in: aRoom ?? room, token: token)

            completion()
        }
    }

    func setup(for user: String, in room: String, token: String) {

        hmsSDK = HMSSDK.build { sdk in
            sdk.logLevel = .verbose
            sdk.analyticsLevel = .verbose
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

        config = HMSConfig(userName: user,
                               userID: UUID().uuidString,
                               roomID: room,
                               authToken: token)

        guard let config = config else { return }
        hmsSDK?.preview(config: config, delegate: self)
    }
    
    func join() {
        guard let config = config else { return }
        hmsSDK?.join(config: config, delegate: self)
    }
    
    func leave() {
        hmsSDK?.leave()
    }
    
    func changeRole(for peer: HMSRemotePeer, to role: String) {
        hmsSDK?.changeRole(for: peer, to: role)
    }
    
    func accept(cahngeRole request: HMSRoleChangeRequest) {
        hmsSDK?.accept(changeRole: request)
    }

    // MARK: - HMSSDK Update Callbacks

    func on(join room: HMSRoom) {
        if let peer = room.peers.first {
            NotificationCenter.default.post(name: Constants.joinedRoom, object: nil, userInfo: ["peer": peer])
        }
    }

    func on(room: HMSRoom, update: HMSRoomUpdate) {
    }

    func on(peer: HMSPeer, update: HMSPeerUpdate) {
        NotificationCenter.default.post(name: Constants.peersUpdated, object: nil, userInfo: ["peer": peer])

        switch update {
        case .peerJoined:
            Utilities.showToast(message: "🙌 \(peer.name) joined! ")
        case .peerLeft:
            Utilities.showToast(message: "👋 \(peer.name) left!")
        default:
            print(#function, peer.name, update)
        }
    }

    func on(track: HMSTrack, update: HMSTrackUpdate, for peer: HMSPeer) {
    }

    func on(error: HMSError) {
        NotificationCenter.default.post(name: Constants.gotError,
                                        object: nil,
                                        userInfo: ["error": error.message])
    }

    func on(message: HMSMessage) {

        messages.append(message)
        NotificationCenter.default.post(name: Constants.messageReceived, object: nil)
    }

    func on(updated speakers: [HMSSpeaker]) {
//        print(speakers)
    }
    
    func on(roleChangeRequest: HMSRoleChangeRequest) {
        onRoleChange?(roleChangeRequest)
    }

    func onReconnecting() {
        print("Reconnecting")
    }

    func onReconnected() {
        print("Reconnected")
    }
}

extension HMSSDKInteractor: HMSPreviewListener {
    func onPreview(room: HMSRoom, localTracks: [HMSTrack]) {
        onPreview?(room, localTracks)
    }
}

extension HMSSDKInteractor: HMSLogger {
    func log(_ message: String, _ level: HMSLogLevel) {
        guard let logLevel = hmsSDK?.logLevel, logLevel.rawValue >= level.rawValue else { return }
        print(message)
    }
}
