//
//  QuizVoteQuestionOptionView.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI

struct QuizVoteQuestionOptionView: View {
    @ObservedObject var model: PollVoteQuestionOptionViewModel
    var body: some View {
        HStack {
            if model.isCorrect == true {
                Image(systemName: model.imageName).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph)
            }
            Text(model.text).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14)
            
            if model.selected {
                Spacer()
                Text("Your Answer").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14)
            }
        }
    }
}
