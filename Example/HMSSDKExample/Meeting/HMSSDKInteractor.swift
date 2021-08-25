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
    internal var onChangeTrackState: ((HMSChangeTrackStateRequest) -> Void)?
    internal var onRemovedFromRoom: ((HMSRemovedFromRoomNotification) -> Void)?
    
    // MARK: - Instance Properties
    
    internal var messages = [HMSMessage]()
    
    private var config: HMSConfig?
    
    var roles: [HMSRole]? {
        hmsSDK?.roles
    }
    
    var currentRole: HMSRole? {
        hmsSDK?.localPeer?.role
    }
    
    
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
    
    func changeRole(for peer: HMSPeer, to role: HMSRole, force: Bool = false) {
        hmsSDK?.changeRole(for: peer, to: role, force: force)
    }
    
    func accept(changeRole request: HMSRoleChangeRequest) {
        hmsSDK?.accept(changeRole: request)
    }
        
    // MARK: - HMSSDK Update Callbacks
    
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
            }
        default:
            print(#function, "Unhandled update type encountered")
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
        Utilities.showToast(message: "💬 \(message.sender!.name) sent you a message")
    }
    
    func on(updated speakers: [HMSSpeaker]) {
    }
    
    func on(room: HMSRoom, update: HMSRoomUpdate) {
        print(#function, room.name, update.description)
    }
    
    func on(roleChangeRequest: HMSRoleChangeRequest) {
        print(#function, roleChangeRequest.requestedBy.name, roleChangeRequest.suggestedRole.name)
        onRoleChange?(roleChangeRequest)
    }
    
    func onReconnecting() {
        print(#function, "Reconnecting")
    }
    
    func onReconnected() {
        print(#function, "Reconnected")
    }
    
    func on(changeTrackStateRequest: HMSChangeTrackStateRequest) {
        onChangeTrackState?(changeTrackStateRequest)
    }
    
    func on(removedFromRoom notification: HMSRemovedFromRoomNotification) {
        onRemovedFromRoom?(notification)
    }
}

extension HMSSDKInteractor: HMSPreviewListener {
    func onPreview(room: HMSRoom, localTracks: [HMSTrack]) {
        print(#function, localTracks.map{ $0.kind.rawValue }, localTracks.map{ $0.source.rawValue })
        onPreview?(room, localTracks)
    }
}

extension HMSSDKInteractor: HMSLogger {
    func log(_ message: String, _ level: HMSLogLevel) {
        guard level.rawValue >= HMSLogLevel.verbose.rawValue else { return }
        print(message)
    }
}
