//
//  PollVoteQuestionOptionView.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI

struct PollVoteQuestionOptionView: View {
    @ObservedObject var model: PollVoteQuestionOptionViewModel
    
    var body: some View {
        Button {
            model.select()
        } label: {
            HStack(spacing: 18) {
                if model.canVote || !model.canViewResponses {
                    Image(systemName: model.imageName).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph)
                }
                VStack {
                    if !model.canVote && model.canViewResponses {
                        HStack {
                            Text(model.text).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14)
                            Spacer()
                            Text("\(model.voteCount) vote\(model.voteCount == 1 ? "" : "s")").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textMediumEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14)
                        }
                        ProgressView(value: model.progress).progressViewStyle(.linear)
                    } else {
                        Text(model.text).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14)
                    }
                }
            }
        }.allowsHitTesting(model.canVote)
    }
}

