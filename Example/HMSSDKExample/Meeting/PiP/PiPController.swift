//
//  PiPController.swift
//  HMSSDKExample
//
//  Created by Pawan Dixit on 08/06/22.
//  Copyright © 2022 100ms. All rights reserved.
//

import AVKit
import HMSSDK
import SwiftUI

class PiPModel: ObservableObject {
    @Published var track: HMSVideoTrack?
    @Published var name: String?
    @Published var screenTrack: HMSVideoTrack?
    @Published var isVideoActive = false
    
    @Published var pipViewEnabled = false
    @Published var roomEndedString: String?
}

class PiPController: NSObject {
    
    let model = PiPModel()
    
    var pipController: AVPictureInPictureController? = nil
    var pipVideoCallViewController: UIViewController? = nil
    
    weak var targetView: UIView?
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
 
    func setup(with targetView: UIView) {
        
        guard #available(iOS 15.0, *) else { return }
        
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }
        
        self.targetView = targetView

        let pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
        self.pipVideoCallViewController = pipVideoCallViewController
        
        let controller = UIHostingController(rootView: PiPView(model: model))
        
        pipVideoCallViewController.view.addConstrained(subview: controller.view)
        
        pipVideoCallViewController.preferredContentSize = targetView.frame.size
        
        let pipContentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: targetView,
            contentViewController: pipVideoCallViewController)
        
        
        self.pipController = AVPictureInPictureController(contentSource: pipContentSource)
        
        self.pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        
        self.pipController?.delegate = self
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) {[weak self] _ in
            self?.stopPiP()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.hmsTrackStateDidChange, object: nil, queue: .main) {[weak self] _ in
            guard let self = self else {return}
            
            if let videoTrack = self.model.track {
                self.model.isVideoActive = !videoTrack.isMute() && !videoTrack.isDegraded()
            }
            else {
                self.model.isVideoActive = false
            }
        }
    }
    
    func update(speaker: HMSSpeaker) {
        model.name = speaker.peer.name
        
        if let videoTrack = speaker.peer.videoTrack {
            model.track = videoTrack
            
            if !videoTrack.isMute() && !videoTrack.isDegraded() {
                model.isVideoActive = true
            }
            else {
                model.isVideoActive = false
            }
        }
        else {

            model.isVideoActive = false
        }
    }
    
    func update(track: HMSVideoTrack, name: String?) {
        model.track = track
        model.name = name
        
        model.isVideoActive = !track.isMute() && !track.isDegraded()
    }
    
    func set(screenTrack: HMSVideoTrack) {
        
        model.screenTrack = screenTrack
        pipVideoCallViewController?.preferredContentSize = .init(width: 1920, height: 1080)
    }
    
    func remove(screenTrack: HMSVideoTrack) {
        model.screenTrack = nil
        
        if let targetView = self.targetView {
            pipVideoCallViewController?.preferredContentSize = targetView.frame.size
        }
    }

    func stopPiP() {
        self.pipController?.stopPictureInPicture()
    }
    
    func roomEnded(reason: String) {
        model.roomEndedString = reason
    }
}

extension PiPController: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        model.pipViewEnabled = true
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        model.pipViewEnabled = false
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        model.pipViewEnabled = false
        assertionFailure("failedToStartPictureInPictureWithError \(error)")
    }
}
