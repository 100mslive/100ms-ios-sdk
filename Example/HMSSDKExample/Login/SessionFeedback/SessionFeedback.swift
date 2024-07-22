//
//  SessionFeedback.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 10/05/24.
//  Copyright © 2024 100ms. All rights reserved.
//

import Foundation

class SessionFeedback {
    static let feedbackTitle = "How was your experience?"
    static let feedbackSubTitle = "Your answers help us improve the quality"
    static let awful = "😔 Awful"
    static let bad = "☹️ Bad"
    static let fair = "🙂 Fair"
    static let good = "😄 Good"
    static let great = "🤩 Great"
}


internal enum HMSFeedbackRatingUI {
    case awful
    case bad
    case fair
    case good
    case great
    
    func toString() -> String {
        switch self {
        case .awful:
            return "😔 Awful"
        case .bad:
            return "☹️ Bad"
        case .fair:
            return "🙂 Fair"
        case .good:
            return "😄 Good"
        case .great:
            return "🤩 Great"
        }
    }
    
    func toInt() -> Int {
        switch self {
        case .awful:
            return 1
        case .bad:
            return 2
        case .fair:
            return 3
        case .good:
            return 4
        case .great:
            return 5
        }
    }
    
    func getQuestion() -> String {
        switch self {
        case .awful, .bad:
            return "What went wrong?"
        case .fair:
            return "Any reason for your rating?"
        case .good, .great:
            return "What went right?"
        }
    }
}
