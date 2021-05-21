//
//  Constants.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation

struct Constants {

    // MARK: - HMSSDK Interactor

    static let tokenEndpoint = <#InsertTokenEndpointHere#>
    
    static let tokenQuery = "api/token"
    
    static let getTokenURL = tokenEndpoint + tokenQuery

    static let defaultRoomID = ""

    static let tokenKey = "token"

    static let idKey = "id"

    static let roomIDKey = "roomID"

    static let hostKey = "host"

    // MARK: - Notifications

    static let hmsError = NSNotification.Name("HMS_ERROR")

    static let settingsUpdated = NSNotification.Name("SETTINGS_UPDATED")

    static let messageReceived = NSNotification.Name("MESSAGE_RECEIVED")

    static let joinedRoom = NSNotification.Name("JOINED_ROOM")

    static let gotError = NSNotification.Name("GOT_ERROR")

    static let peersUpdated = NSNotification.Name("PEERS_UPDATED")

    static let speakerUpdated = NSNotification.Name("SPEAKER_UPDATED")

    static let pinTapped = NSNotification.Name("PIN_TAPPED")

    static let updatePinnedView = NSNotification.Name("UPDATE_PINNED_VIEW")

    static let muteALL = NSNotification.Name("MUTE_ALL")

    static let peerVideoToggled = NSNotification.Name("LOCAL_VIDEO_TOGGLED")

    static let peerAudioToggled = NSNotification.Name("LOCAL_AUDIO_TOGGLED")

    static let deeplinkTapped = NSNotification.Name("DEEPLINK_TAPPED")

    static let appInBackground = NSNotification.Name("APP_BACKGROUND")

    static let updatedSpeaker = Notification.Name("UPDATED_SPEAKERS")

    static let stopVideoTapped = Notification.Name("STOP_VIDEO_TAPPED")

    // MARK: - View Constants

    static let meeting = "Meeting"

    static let settings = "Settings"

    static let chat = "Chat"

    static let peersList = "PeersList"

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

    static let maximumRows = "maximumRows"

    static let audioPollDelay = "audioPollDelay"

    static let silenceThreshold = "silenceThreshold"

    static let mirrorMyVideo = "mirrorMyVideo"

    static let showVideoPreview = "showVideoPreview"

    static let videoFrameRate = "videoFrameRate"

    static let audioBitRate = "audioBitRate"

    static let defaultVideoSource = "defaultVideoSource"

    static let videoResolution = "videoResolution"

    static let videoBitRate = "videoBitRate"
}