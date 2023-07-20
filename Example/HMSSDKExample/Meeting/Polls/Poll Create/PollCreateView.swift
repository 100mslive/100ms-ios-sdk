//
//  PollCreateView.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 18.05.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI
import HMSSDK

struct PollCreateView: View {
    @ObservedObject var model: PollCreateModel

    init(model: PollCreateModel) {
        self.model = model
    }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("", systemImage: "chevron.left").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph)
                    }
                    Text("Poll/Quiz").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.heading6Semibold20)
                    Spacer().frame(height: 16)
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("", systemImage: "xmark").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph)
                    }
                    
                }.padding(.horizontal, 24)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Group {
                            Spacer().frame(height: 16)
                            Text("Select the type you want to continue with").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textMediumEmph).font(HMSUIThemeCenter.sharedTheme.fonts.captionRegular)
                            Spacer().frame(height: 16)
                            HStack(spacing: 16) {
                                PollTypeButton(text: "Poll", icon: "chart.bar.fill", selected: model.selectedCategory == .poll) {
                                    model.selectedCategory = .poll
                                }
                                PollTypeButton(text: "Quiz", icon: "questionmark.circle", selected: model.selectedCategory == .quiz) {
                                    model.selectedCategory = .quiz
                                }
                            }
                            Spacer().frame(height: 16)
                        }
                        
                        Group {
                            Text("Name this \(model.selectedCategory == .poll ? "poll" : "quiz")").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14)
                            Spacer().frame(height: 8)
                            PollTextField(placeholder: "My \(model.selectedCategory == .poll ? "Poll" : "Quiz")", text: $model.pollTitle, valid: model.valid)
                            Spacer().frame(height: 24)
                        }
                        
                        Group {
                            SwitchView(text: "Hide vote count", isOn: $model.hideVotes)
                            Spacer().frame(height: 24)
                            SwitchView(text: "Make results anonymous", isOn: $model.anonymous)
                            Spacer().frame(height: 24)
                            HStack {
                                SwitchView(text: "Timer", isOn: $model.enableTimer)
                                Spacer()
                                HMSPickerField(title: "", options: model.timerDurationOptions, selectedOption: $model.selectedTimerDuration).opacity(model.enableTimer ? 1 : 0)
                            }
                            Spacer().frame(height: 24)
                            
                        }
                        
                        Group {
                            if !model.valid {
                                Text(model.errorMessage).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.alertError).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14)
                                Spacer().frame(height: 16)
                            }
                            
                            NavigationLink(destination: PollQuestionsCreateView(model: model.questionModel), isActive: $model.isShowingQuestionView) {
                                EmptyView()
                            }
                            
                            Button("Create \(model.selectedCategory == .poll ? "Poll" : "Quiz")") {
                                model.createPoll()
                            }.buttonStyle(ActionButtonStyle())
                            
                            Spacer(minLength: 24)
                        }
                        
                        if !model.currentPolls.isEmpty {
                            VStack(alignment: .leading, spacing: 24) {
                                Text("Previous Polls/Quizzes").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.heading6Semibold20)
                                ForEach(model.currentPolls) { pollListModel in
                                    NavigationLink() {
                                        if let createModel = pollListModel.createModel {
                                            PollQuestionsCreateView(model: QuestionCreateViewModel(pollModel: createModel)) }
                                        else if let resultModel = pollListModel.resultModel {
                                            PollVoteView(model: resultModel)
                                        }
                                    } label: {
                                        PollListEntryView(model: pollListModel)
                                    }
                                }
                            }
                        }
                    }.padding(.horizontal, 24)
                }
            }.background(HMSUIThemeCenter.sharedTheme.colors.surfaceDefault).ignoresSafeArea().onAppear {
                model.refreshPolls()
            }
        }
    }
}
