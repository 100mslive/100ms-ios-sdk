//
//  PollQuestionsView.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI

struct PollQuestionsView: View {
    @ObservedObject var model: QuestionCreateModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("QUESTION \(model.index) of \(model.count)").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textMediumEmph).font(HMSUIThemeCenter.sharedTheme.fonts.captionRegular).frame(maxWidth: .infinity, alignment: .leading)

            if model.editing {
                HMSPickerField(title:"Question Type", options: model.options, selectedOption: $model.selectedOption)
                PollTextField(placeholder: "Ask a question", text: $model.text, valid: model.valid)
            } else {
                Text(model.text).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body1Regular16)
            }
            
            if (model.editing ) {
                if (model.type == .singleChoice || model.type == .multipleChoice) {
                    Text("Options").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textMediumEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14)
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(model.questionOptions) { option in
                            PollOptionView(model: option)
                        }
                    }
                    
                    if model.editing {
                        Button {
                            model.addOption()
                        } label: {
                            Label("Add an option", systemImage: "plus.circle")
                        }.buttonStyle(HMSIconTextButtonStyle())
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(model.questionOptions) { option in
                        Text(option.text).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textMediumEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14)
                    }
                }
            }
            if !model.valid || !model.optionsValid {
                Text("Please fill the fields to Save.").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.alertError).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14)
            }
            HStack {
                if model.index > 1 {
                    Button {
                        model.delete()
                    } label: {
                        Label("", systemImage: "trash")
                    }.buttonStyle(HMSIconTextButtonStyle()).allowsHitTesting(!model.loading).opacity(model.loading ? 0 : 1 )
                }
                Spacer()
                
                Button {
                    model.editing ? model.save() : model.edit()
                } label: {
                    if model.loading {
                        ProgressView()
                    } else {
                        Text(model.editing ? "Save" : "Edit")
                    }
                }.buttonStyle(ActionButtonLowEmphStyle()).allowsHitTesting(!model.loading)
            }
        }.padding(16).background(HMSUIThemeCenter.sharedTheme.colors.surfaceLight).clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

