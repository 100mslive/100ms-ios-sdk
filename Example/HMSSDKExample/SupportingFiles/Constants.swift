//
//  Constants.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 04/08/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation

/// No Modifications required here. Ensure you have entered correct Token endpoint in the TokenEndpoint.swift file
struct Constants {

    // MARK: Room Setup

    static let tokenKey = "token"

    static let idKey = "id"

    static let roomIDKey = "roomID"

    static let hostKey = "host"

    // MARK: - Notifications

    static let hmsError = NSNotification.Name("HMS_ERROR")

    static let settingsUpdated = NSNotification.Name("SETTINGS_UPDATED")

    static let messageReceived = NSNotification.Name("MESSAGE_RECEIVED")

    static let joinedRoom = NSNotification.Name("JOINED_ROOM")

    static let trackStatsUpdated = NSNotification.Name("TRACK_STATS_UPDATED")

    static let gotError = NSNotification.Name("GOT_ERROR")

    static let peersUpdated = NSNotification.Name("PEERS_UPDATED")

    static let speakerUpdated = NSNotification.Name("SPEAKER_UPDATED")

    static let pinTapped = NSNotification.Name("PIN_TAPPED")

    static let updatePinnedView = NSNotification.Name("UPDATE_PINNED_VIEW")

    static let muteALL = NSNotification.Name("MUTE_ALL")

    static let deeplinkTapped = NSNotification.Name("DEEPLINK_TAPPED")

    static let appInBackground = NSNotification.Name("APP_BACKGROUND")

    static let updatedSpeaker = Notification.Name("UPDATED_SPEAKERS")

    static let toggleVideoTapped = Notification.Name("TOGGLE_VIDEO_TAPPED")
    
    static let switchCameraTapped = Notification.Name("SWITCH_CAMERA_TAPPED")

    static let updateVideoCellButton = Notification.Name("UPDATE_VIDEO_CELL_BUTTON")

    static let toggleAudioTapped = Notification.Name("TOGGLE_AUDIO_TAPPED")

    static let roleUpdated = Notification.Name("ROLE_UPDATED")
    
    static let sessionMetadataReceived = NSNotification.Name("sessionMetadataReceived")

    // MARK: - View Constants

    static let meeting = "Meeting"

    static let previewControllerIdentifier = "PreviewController"

    static let settings = "Settings"

    static let chat = "Chat"

    static let peersList = "PeersList"
    static let peersListPreview = "PeersListPreview"

    static let emptyFields = "Please fill in all fields!"

    static let meetingError = "Could not make Meeting View Controller!"

    static let resuseIdentifier = "Cell"

    static let chatSenderName = "senderName"

    static let chatMessage = "msg"

    static let peerID = "peerID"

    static let indexesToBeUpdated = "indexesToBeUpdated"

    // MARK: - Settings

    static let defaultName = "defaultName"
    
    static let roomName = "roomName"

    static let publishVideo = "publishVideo"

    static let publishAudio = "publishAudio"

    static let mirrorMyVideo = "mirrorMyVideo"

    static let showVideoPreview = "showVideoPreview"

    static let showStats = "showStats"
    static let testMode = "testMode"
    static let musicMode = "musicMode"
    
    static let autoSimulcastLayerSelection = "autoSimulcastLayerSelection"

    static let defaultVideoSource = "defaultVideoSource"
    
    static let defaultAudioSource = "defaultAudioSource"
    
    static let disablePiP = "disablePiP"
    static let enableOrientationLock = "enableOrientationLock"
    
    static var logFoloderURL: URL? = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    }()
    
    static var logFileName = "100ms.log"
    
    static var logFileURL: URL? = {
        logFoloderURL?.appendingPathComponent(logFileName, isDirectory: false)
    }()
}

enum ViewModes: String {
    case regular, audioOnly, videoOnly, speakers, pinned, spotlight, hero
}

enum AudioSourceType: Int, CaseIterable {
    case audioMixer, webrtc
    
    var description: String {
        switch self {
        case .audioMixer:
            return "Audio Mixer"
        case .webrtc:
            return "Webrtc"
        }
    }
}
