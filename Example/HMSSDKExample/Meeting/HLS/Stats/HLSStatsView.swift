//
//  HLSStatsView.swift
//  HMSSDKExample
//
//  Created by Pawan Dixit on 19/10/2022.
//  Copyright © 2022 100ms. All rights reserved.
//

import SwiftUI

struct HLSStatsView: View {
    
    @ObservedObject var model: HLSStatsModel
    @State var alternateAppearance = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Estimated Bandwidth: \(model.observedBitrate.digitsRemovedFromEnd()) Kbps")
            Text("Bitrate: \(model.streamBitrate.digitsRemovedFromEnd()) Kbps")
            Text("BytesDownloaded: \(model.bytesDownloaded) KB")
            Text("BufferedDuration: \(model.bufferedDuration.digitsRemovedFromEnd()) ms")
            Text("DistanceFromLiveEdge: \(model.distanceFromLiveEdge.digitsRemovedFromEnd()) ms")
            Text("DroppedFrames: \(model.droppedFrames) frames")
            Text("VideoSize: \(model.videoSize.width.digitsRemovedFromEnd()) X \(model.videoSize.height.digitsRemovedFromEnd())")
            Text("WatchDuration: \(model.watchDuration.digitsRemovedFromEnd()) ms")
        }
        .minimumScaleFactor(0.1)
        .foregroundColor(alternateAppearance ? .white : .blue)
        .padding()
        .background(alternateAppearance ? Color.blue : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            alternateAppearance.toggle()
        }
    }
}

extension Double {
    func digitsRemovedFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
}
extension CGFloat {
    func digitsRemovedFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
}
