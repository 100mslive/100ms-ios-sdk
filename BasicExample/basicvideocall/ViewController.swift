//
//  ViewController.swift
//  basicvideocall
//
//  Created by Dmitry Fedoseyev on 27.07.2021.
//

import UIKit
import HMSSDK

class ViewController: UIViewController {
    var hmsSDK = HMSSDK.build()
    lazy var stackView: UIStackView = {
        let result = UIStackView()
        result.axis = .vertical
        
        view.addSubview(result)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        result.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        result.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        let heightConstraint =  result.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        heightConstraint.priority = .defaultLow
        
        return result
    }()
    
    var trackViewMap = [HMSTrack: HMSVideoView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinRoom()
    }
    
    func joinRoom() {
        let config = HMSConfig(userID: UUID().uuidString, roomID: "inset room id", authToken: "inset token here")
        hmsSDK.join(config: config, delegate: self)
        hmsSDK.localPeer?.localAudioTrack()?.setMute(true)
        hmsSDK.localPeer?.localVideoTrack()?.setMute(true)
        hmsSDK.leave()
    }
    
    func addVideoView(for track: HMSVideoTrack) {
        let videoView = HMSVideoView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.setVideoTrack(track)
        videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: 9.0/16.0).isActive = true
        stackView.addArrangedSubview(videoView)
        trackViewMap[track] = videoView
    }
    
    func removeVideoView(for track: HMSVideoTrack) {
        trackViewMap[track]?.removeFromSuperview()
    }
}

extension ViewController: HMSUpdateListener {
    func on(join room: HMSRoom) {
    }
    
    func on(room: HMSRoom, update: HMSRoomUpdate) {
        
    }
    
    func on(peer: HMSPeer, update: HMSPeerUpdate) {
        switch update {
        case .peerLeft:
            if let videoTrack = peer.videoTrack {
                removeVideoView(for: videoTrack)
            }
        default:
            break
        }
    }
    
    func on(track: HMSTrack, update: HMSTrackUpdate, for peer: HMSPeer) {
        switch update {
        case .trackAdded:
            if let videoTrack = track as? HMSVideoTrack {
                addVideoView(for: videoTrack)
            }
        case .trackRemoved:
            if let videoTrack = track as? HMSVideoTrack {
                removeVideoView(for: videoTrack)
            }
        default:
            break
        }
    }
    
    func on(error: HMSError) {
        print(error.description)
    }
    
    func on(message: HMSMessage) {
        
    }
    
    func on(updated speakers: [HMSSpeaker]) {
        
    }
    
    func onReconnecting() {
        
    }
    
    func onReconnected() {
        
    }
}
