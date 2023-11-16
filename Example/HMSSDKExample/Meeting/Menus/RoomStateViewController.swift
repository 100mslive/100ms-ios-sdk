//
//  RoomStateViewController.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 03.03.2022.
//  Copyright © 2022 100ms. All rights reserved.
//

import UIKit
import Eureka
import HMSSDK

class RoomStateViewController: FormViewController {
    var room: HMSRoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRoomInfo()
        setupServerRecording()
        setupBrowserRecording()
        setupHLSRecording()
        setupRTMPStreaming()
        setupHLSStreaming()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Room state"
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setupRoomInfo() {
        let section = Section("Room info")
        
        section <<< LabelRow() {
            $0.title = "Room id: \(room.roomID ?? "N/A")"
        }
        
        section <<< LabelRow() {
            $0.title = "Room name: \(room.name ?? "N/A")"
        }
        
        section <<< LabelRow() {
            $0.title = "Peer count: \(room.peerCount ?? 0)"
        }
        
        if let metadata = room.metaData {
            section <<< LabelRow() {
                $0.title = "Room meta: \(metadata)"
            }
        }
        form +++ section
    }

    func setupBrowserRecording() {
        let section = Section("Browser recording")
        
        let state = room.browserRecordingState.state
        section <<< LabelRow() {
            $0.title = "State: \(state.displayString())"
        }
    
        if let startDate = room.browserRecordingState.startedAt {
            section <<< LabelRow() {
                $0.title = "Started at: \(startDate)"
            }
        }
        
        if let error = room.browserRecordingState.error as? HMSError {
            section <<< LabelRow() {
                $0.title = "Error: \(error.localizedDescription)"
            }
        }
        form +++ section
    }
    
    func setupServerRecording() {
        let section = Section("Server recording")

        let state = room.serverRecordingState.state
        section <<< LabelRow() {
            $0.title = "State: \(state.displayString())"
        }
        
        if let startDate = room.serverRecordingState.startedAt {
            section <<< LabelRow() {
                $0.title = "Started at: \(startDate)"
            }
        }
        if let error = room.serverRecordingState.error as? HMSError {
            section <<< LabelRow() {
                $0.title = "Error: \(error.localizedDescription)"
            }
        }
        form +++ section
    }
    
    func setupHLSRecording() {
        let section = Section("HLS recording")

        let state = room.hlsRecordingState.state
        section <<< LabelRow() {
            $0.title = "State: \(state.displayString())"
        }
        

        if let startDate = room.hlsRecordingState.startedAt {
            section <<< LabelRow() {
                $0.title = "Started at: \(startDate)"
            }
        }
        
        if let error = room.hlsRecordingState.error as? HMSError {
            section <<< LabelRow() {
                $0.title = "Error: \(error.localizedDescription)"
            }
        }
        
        form +++ section
    }
    
    func setupRTMPStreaming() {
        let section = Section("RTMP")

        let state = room.rtmpStreamingState.state
        section <<< LabelRow() {
            $0.title = "State: \(state.displayString())"
        }

        if let startDate = room.rtmpStreamingState.startedAt {
            section <<< LabelRow() {
                $0.title = "Started at: \(startDate)"
            }
        }
        if let error = room.rtmpStreamingState.error as? HMSError {
            section <<< LabelRow() {
                $0.title = "Error: \(error.localizedDescription)"
            }
        }
        form +++ section
    }
    
    func setupHLSStreaming() {
        let section = Section("HLS")
        
        let state = room.hlsStreamingState.state
        section <<< LabelRow() {
            $0.title = "State: \(state.displayString())"
        }
        
        var count = 1
        for variant in room.hlsStreamingState.variants {
            section <<< TextAreaRow() {
                $0.value = "Variant \(count): \(variant.url)"
            }
            if let startDate = variant.startedAt {
                section <<< LabelRow() {
                    $0.title = "Started at: \(startDate)"
                }
            }
            count += 1
        }
        
        if let error = room.rtmpStreamingState.error as? HMSError {
            section <<< LabelRow() {
                $0.title = "Error: \(error.localizedDescription)"
            }
        }
        form +++ section
    }
    
}
