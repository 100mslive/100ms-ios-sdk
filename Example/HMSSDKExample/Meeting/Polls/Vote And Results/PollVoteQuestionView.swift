//
//  PollVoteQuestionView.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI

struct PollVoteQuestionView: View {
    @ObservedObject var model: PollVoteQuestionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("QUESTION \(model.index) of \(model.count)").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textMediumEmph).font(HMSUIThemeCenter.sharedTheme.fonts.captionRegular)
            
            HStack{
                Text(model.text).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body1Regular16)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 16) {
                if model.poll.category == .poll || model.canVote || model.poll.state == .stopped {
                    ForEach(model.questionOptions) { option in
                        PollVoteQuestionOptionView(model: option)
                    }
                } else {
                    ForEach(model.questionOptions) { option in
                        QuizVoteQuestionOptionView(model: option)
                    }
                }
            }
            
            if model.canVote {
                HStack(spacing: 8) {
                    Spacer()
                    
                    if model.canSkip {
                        Button {
                            
                        } label: {
                            Text("Skip")
                        }.buttonStyle(ActionButtonLowEmphStyle())
                    }
                    
                    Button {
                        model.vote()
                    } label: {
                        Text("Vote")
                    }.buttonStyle(ActionButtonStyle(isWide: false))
                }
            }
             
        }.padding(16).background(HMSUIThemeCenter.sharedTheme.colors.surfaceLight).overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(model.borderColor, lineWidth: 1)).clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
