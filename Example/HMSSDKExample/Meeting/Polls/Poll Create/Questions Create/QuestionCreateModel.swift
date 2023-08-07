//
//  QuestionCreateModel.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import Foundation
import HMSSDK

class QuestionCreateModel: ObservableObject, Identifiable {
    internal init(pollModel: PollCreateModel, index: Int, count: Int, showAnswerSelection: Bool, saved: Bool, onSave: @escaping ((QuestionCreateModel)->Void), onDelete: @escaping ((QuestionCreateModel)->Void)) {
        self.index = index
        self.count = count
        self.showAnswerSelection = showAnswerSelection
        self.questionOptions = [QuestionOptionCreateModel]()
        self.pollModel = pollModel
        self.onSave = onSave
        self.onDelete = onDelete
        self.saved = saved
        addOption()
        addOption()
    }
    
    internal init(pollModel: PollCreateModel, index: Int, count: Int, question: HMSPollQuestion, saved: Bool, onSave: @escaping ((QuestionCreateModel)->Void), onDelete: @escaping ((QuestionCreateModel)->Void)) {
        self.index = index
        self.count = count
        self.showAnswerSelection = pollModel.createdPoll?.category == .quiz
        self.questionOptions = [QuestionOptionCreateModel]()
        self.pollModel = pollModel
        self.onSave = onSave
        self.onDelete = onDelete
        self.saved = saved
        self.editing = false
        self.text = question.text
        self.type = question.type
        self.selectedOption = question.type.toDisplayString()
        
        populateOptions(from: question.options, answer: question.answer)
    }
    
    var pollModel: PollCreateModel
    
    @Published var text: String = ""
    @Published var saved: Bool = false
    @Published var loading: Bool = false
    @Published var editing: Bool = true
    @Published var valid: Bool = true
    @Published var optionsValid: Bool = true
    @Published var questionOptions: [QuestionOptionCreateModel]
    @Published var index: Int = 1
    @Published var count: Int = 1
    @Published var type: HMSPollQuestionType = .singleChoice
    @Published var options = [HMSPollQuestionType.singleChoice, HMSPollQuestionType.multipleChoice].map({ $0.toDisplayString() })
    @Published var selectedOption = HMSPollQuestionType.singleChoice.toDisplayString() {
        didSet {
            updateOptionType()
        }
    }
    var showAnswerSelection: Bool
    var onSave: ((QuestionCreateModel)->Void)
    var onDelete: ((QuestionCreateModel)->Void)
    
    func updateOptionType() {
        for questionType in HMSPollQuestionType.allCases {
            if questionType.toDisplayString() == selectedOption {
                self.type = questionType
            }
        }
        
        for option in questionOptions {
            option.selected = false
            option.isSingleChoice = self.type == .singleChoice
        }
    }
    
    func populateOptions(from options: [HMSPollQuestionOption]?, answer: HMSPollQuestionAnswer?) {
        guard let options = options else {
            addOption()
            addOption()
            return
        }
        
        var selectedIndexes = Set<Int>()
        if let answer = answer {
            if type == .singleChoice, let index = answer.option {
                selectedIndexes.insert(index)
            } else if type == .multipleChoice, let indexes = answer.options {
                selectedIndexes.formUnion(indexes)
            }
        }
        
        for option in options {
            addOption(text: option.text, selected: selectedIndexes.contains(option.index))
        }
    }
    
    func addOption(text: String = "", selected: Bool = false) {
        let newCount = questionOptions.count + 1
        
        let selection: ((QuestionOptionCreateModel)->Void) = { [weak self] selectedModel in
            guard selectedModel.isSingleChoice, let options = self?.questionOptions else { return }
            for optionModel in options {
                optionModel.selected = optionModel.index == selectedModel.index
            }
        }
        
        let result = QuestionOptionCreateModel(index: newCount, showAnswerSelection: showAnswerSelection, isSingleChoice: self.type == .singleChoice, onSelectionChange: selection)
        result.text = text
        result.selected = selected
        
        questionOptions.append(result)
    }
    
    func save() {
        onSave(self)
    }
    
    func delete() {
        onDelete(self)
    }
    
    func edit() {
        editing = true
    }
}
