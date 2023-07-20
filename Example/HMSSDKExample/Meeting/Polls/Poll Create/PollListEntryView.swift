//
//  PollListEntryView.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI
import HMSSDK

class PollListModel: ObservableObject, Identifiable {
    internal init(poll: HMSPoll, resultModel: PollVoteViewModel?, createModel: PollCreateModel?) {
        self.resultModel = resultModel
        self.createModel = createModel
        self.title = poll.title
        self.state = poll.state
        if let startDate = poll.startedAt, poll.duration > 0 {
            self.endDate =  startDate.addingTimeInterval(TimeInterval(poll.duration))
        }
    }
    
    var title: String
    var state: HMSPollState
    
    var createModel: PollCreateModel?
    var resultModel: PollVoteViewModel?
    var endDate: Date?
}

struct PollListEntryView: View {
   @ObservedObject var model: PollListModel
   
   var body: some View {
       HStack(alignment: .top) {
           Text(model.title).font(HMSUIThemeCenter.sharedTheme.fonts.subtitle1)
               .foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph)
           Spacer()
           VStack(alignment: .trailing, spacing: 16) {
               PollStateBadgeView(pollState: model.state, endDate: model.endDate)
               Button("View") {
                   
               }.buttonStyle(ActionButtonStyle()).allowsHitTesting(false)
           }.frame(width: 89)
            
       }.padding(16).background(HMSUIThemeCenter.sharedTheme.colors.surfaceLight).clipShape(RoundedRectangle(cornerRadius: 8))
   }
}
