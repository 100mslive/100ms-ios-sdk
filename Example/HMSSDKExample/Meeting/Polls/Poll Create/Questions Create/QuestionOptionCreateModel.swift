//
//  QuestionOptionCreateModel.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import Foundation

class QuestionOptionCreateModel: ObservableObject, Identifiable {
    @Published var text: String = ""
    @Published var selected: Bool = false
    @Published var index: Int = 1
    @Published var isSingleChoice: Bool = false
    @Published var showAnswerSelection: Bool = false
    @Published var valid: Bool = true
    
    var imageName: String {
        let shape = isSingleChoice ? "circle" : "square"
        return selected ? "checkmark.\(shape)" : shape
    }
    
    internal init(index: Int = 1, showAnswerSelection: Bool, isSingleChoice: Bool, onSelectionChange: @escaping ((QuestionOptionCreateModel)->Void)) {
        self.index = index
        self.showAnswerSelection = showAnswerSelection
        self.isSingleChoice = isSingleChoice
        self.onSelectionChange = onSelectionChange
    }
    
    var onSelectionChange: ((QuestionOptionCreateModel)->Void)
    
    func select() {
        selected = !selected
        onSelectionChange(self)
    }
}
