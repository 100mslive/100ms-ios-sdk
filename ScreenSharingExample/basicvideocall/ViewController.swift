//
//  ViewController.swift
//  basicvideocall
//
//  Created by Dmitry Fedoseyev on 27.07.2021.
//

import UIKit
import HMSSDK
import ReplayKit

class ViewController: UIViewController {
    var hmsSDK = HMSSDK.build() { sdk in
        sdk.appGroup = "group.live.100ms.screenshare-example"
    }
    
    let pickerButton: RPSystemBroadcastPickerView = {
        let picker = RPSystemBroadcastPickerView(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        picker.preferredExtension = "live.100ms.screenshare-example.BasicExtension"
        return picker
    }()

    var trackViewMap = [HMSTrack: HMSVideoView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        joinRoom()
    }

    func joinRoom() {
        let config = HMSConfig(userName: "Pawan's iPhone", authToken: "inset token here")
        hmsSDK.join(config: config, delegate: self)
        
        view.addConstrained(subview: pickerButton)
    }
    
    lazy var stackView: UIStackView = {
        let result = UIStackView()
        result.axis = .vertical

        view.addSubview(result)
        view.bringSubviewToFront(pickerButton)
        
        result.translatesAutoresizingMaskIntoConstraints = false
        result.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        result.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        result.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        let heightConstraint =  result.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
        heightConstraint.priority = .defaultLow

        return result
    }()
    
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

    func on(error: Error) {
        print(error.localizedDescription)
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


extension UIView {
    func addConstrained(subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
