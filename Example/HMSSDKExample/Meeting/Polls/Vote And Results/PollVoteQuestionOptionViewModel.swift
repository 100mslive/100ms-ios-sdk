//
//  PollVoteQuestionOptionViewModel.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import Foundation
import HMSSDK

class PollVoteQuestionOptionViewModel: ObservableObject, Identifiable {
    internal init(option: HMSPollQuestionOption, isSingleChoice: Bool, canVote: Bool, selected: Bool, isCorrect: Bool, canViewResponses: Bool, onSelectionChange: @escaping ((PollVoteQuestionOptionViewModel)->Void)) {
        self.isSingleChoice = isSingleChoice
        self.option = option
        self.onSelectionChange = onSelectionChange
        self.canVote = canVote
        self.selected = selected
        self.isCorrect = isCorrect
        self.canViewResponses = canViewResponses
        updateValues()
    }
    
    var option: HMSPollQuestionOption {
        didSet {
            updateValues()
        }
    }
    
    func updateValues() {
        text = option.text
        voteCount = option.voteCount
    }
    
    var imageName: String {
        let shape = isSingleChoice ? "circle" : "square"
        return selected || isCorrect == true ? "checkmark.\(shape)" : shape
    }
    
    @Published var isCorrect: Bool?
    @Published var text: String = ""
    @Published var selected: Bool = false
    @Published var voteCount: Int = 0
    @Published var totalCount: Int = 0 {
        didSet {
            progress = Float(voteCount) / Float(totalCount)
        }
    }
    @Published var progress: Float = 0
    @Published var isSingleChoice: Bool = true
    @Published var canVote: Bool = false
    var canViewResponses: Bool
    
    var onSelectionChange: ((PollVoteQuestionOptionViewModel)->Void)
    
    func select() {
        selected = !selected
        onSelectionChange(self)
    }
}
