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

    internal var hms: HMSSDK?

    // MARK: - Instance Properties

    internal var messages = [HMSMessage]()

    // MARK: - Setup Stream

    init(for user: String,
         in room: String,
         _ flow: MeetingFlow,
         _ role: Int,
         _ completion: @escaping () -> Void) {

        RoomService.setup(for: flow, role, user, room) { [weak self] token, aRoom in
            guard let token = token else {
                print(#function, "Error fetching token")
                return
            }

            self?.setup(for: user, in: aRoom ?? room, token: token)

            completion()
        }
    }

    func setup(for user: String, in room: String, token: String) {

        hms = HMSSDK.build { (hms) in
            hms.logLevel = .verbose
            hms.analyticsLevel = .verbose
            let videoSettings = HMSVideoTrackSettings(codec: .VP8,
                                                      resolution: .init(width: 320, height: 180),
                                                      maxBitrate: 512,
                                                      maxFrameRate: 25,
                                                      cameraFacing: .front,
                                                      trackDescription: "Just a normal video track")
            let audioSettings = HMSAudioTrackSettings(maxBitrate: 32, trackDescription: "Just a normal audio track")
            hms.trackSettings = HMSTrackSettings(videoSettings: videoSettings, audioSettings: audioSettings)
            hms.logger = self
        }

        let config = HMSConfig(userName: user,
                               userID: UUID().uuidString,
                               roomID: room,
                               authToken: token)

        hms?.join(config: config, delegate: self)
    }

    // MARK: - HMSSDK Update Callbacks

    func on(join room: HMSRoom) {
        print(#function)
        if let peer = room.peers.first {
            NotificationCenter.default.post(name: Constants.joinedRoom, object: nil, userInfo: ["peer": peer])
        }
    }

    func on(room: HMSRoom, update: HMSRoomUpdate) {
        print(#function, "update:", update.description)
    }

    func on(peer: HMSPeer, update: HMSPeerUpdate) {
        print(#function, "peer:", peer.name, "update:", update.description)
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
        print(#function, "peer:", peer.name, "track:", track.kind.rawValue, "update:", update.description)
    }

    func on(error: HMSError) {
        print(#function, error.localizedDescription)
        NotificationCenter.default.post(name: Constants.gotError,
                                        object: nil,
                                        userInfo: ["error": error.message])
    }

    func on(message: HMSMessage) {

        print(#function, message)
        messages.append(message)
        NotificationCenter.default.post(name: Constants.messageReceived, object: nil)
    }

    func on(updated speakers: [HMSSpeaker]) {
//        print(speakers)
    }

    func onReconnecting() {
        print("Reconnecting")
    }

    func onReconnected() {
        print("Reconnected")
    }
}

extension HMSSDKInteractor: HMSLumberjack {
    func log(_ message: String, _ level: HMSLogLevel) {
        guard let logLevel = hms?.logLevel, level.rawValue >= logLevel.rawValue else { return }
        print(message)
    }
}
