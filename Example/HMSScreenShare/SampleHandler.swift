//
//  SampleHandler.swift
//  HMSScreenShare
//
//  Created by Pawan Dixit on 21/04/22.
//  Copyright © 2022 100ms. All rights reserved.
//

import HMSBroadcastExtensionSDK

class SampleHandler: HMSBroadcastSampleHandler {
    override var appGroupId: String {
        "group.live.100ms.videoapp"
    }
    
    override var enableAudio: Bool {
        true
    }
}
