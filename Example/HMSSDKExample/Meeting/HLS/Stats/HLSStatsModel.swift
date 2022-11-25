//
//  HLSStatsModel.swift
//  HMSSDKExample
//
//  Created by Pawan Dixit on 19/10/2022.
//  Copyright © 2022 100ms. All rights reserved.
//

import Foundation

class HLSStatsModel: ObservableObject {
    @Published var observedBitrate: Double = 0
    @Published var streamBitrate: Double = 0
    @Published var bytesDownloaded: Int64 = 0
    @Published var bufferedDuration: TimeInterval = 0
    @Published var distanceFromLiveEdge: TimeInterval = 0
    @Published var droppedFrames: Int = 0
    @Published var videoSize: CGSize = .zero
    @Published var watchDuration: TimeInterval = 0
}
