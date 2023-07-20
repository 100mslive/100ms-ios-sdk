//
//  PollQuestionsCreateView.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 25.05.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI
import HMSSDK

struct PollQuestionsCreateView: View {
    internal init(model: QuestionCreateViewModel) {
        self.model = model
    }
    
    @ObservedObject var model: QuestionCreateViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 24)
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("", systemImage: "chevron.left").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph)
                }
                Text(model.pollModel.selectedCategory == .poll ? "Poll" : "Quiz").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.heading6Semibold20)
                Spacer().frame(height: 16)
            }
            Spacer(minLength: 16)
            PollDivider()
            Spacer(minLength: 24)
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(model.questions) { question in
                        PollQuestionsView(model: question)
                    }
                }
                Spacer(minLength: 24)
                HStack {
                    Button {
                        model.addQuestion()
                    } label: {
                        Label("Add another question", systemImage: "plus.circle")
                    }.buttonStyle(HMSIconTextButtonStyle())
                    Spacer()
                }
                Spacer(minLength: 24)
                HStack {
                    Spacer()
                    Button("Launch \(model.pollModel.selectedCategory == .poll ? "Poll" : "Quiz")") {
                        model.startPoll()
                    }.buttonStyle(ActionButtonStyle(isWide: false)).alert(isPresented: $model.showingAlert) {
                        Alert(title: Text("Error"), message: Text(model.alertText), dismissButton: .default(Text("OK")))
                    }
                }
            }
            
            Spacer(minLength: 24)
        }.padding(.horizontal, 24).background(HMSUIThemeCenter.sharedTheme.colors.surfaceDefault).ignoresSafeArea().onAppear {
            model.loadQuestions()
        }.navigationBarHidden(true)
            
    }
}
