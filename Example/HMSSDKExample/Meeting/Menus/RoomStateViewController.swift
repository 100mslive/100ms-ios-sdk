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
        
        if let metadata = room.metaData {
            section <<< LabelRow() {
                $0.title = "Room meta: \(metadata)"
            }
        }
        form +++ section
    }

    func setupBrowserRecording() {
        guard room.browserRecordingState.running || room.browserRecordingState.initialising else { return }
        
        let section = Section("Browser recording")
        
        if room.browserRecordingState.initialising {
            section <<< LabelRow() {
                $0.title = "Initialising"
            }
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
        guard room.serverRecordingState.running else { return }
        
        let section = Section("Server recording")

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
        guard room.hlsRecordingState.running else { return }
        
        let section = Section("HLS recording")
        
        section <<< LabelRow() {
            $0.title = "Single file per layer: \(room.hlsRecordingState.singleFilePerLayer ? "ON" : "OFF")"
        }
        
        section <<< LabelRow() {
            $0.title = "Enable VOD: \(room.hlsRecordingState.enableVOD ? "ON" : "OFF")"
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
        guard room.rtmpStreamingState.running else { return }
        
        let section = Section("RTMP")

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
        guard room.hlsStreamingState.running else { return }
        
        let section = Section("HLS")
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
