//
//  PollSummaryViewModel.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import Foundation

class PollSummaryViewModel: ObservableObject, Identifiable {
    let items: [PollSummaryItemRowViewModel]

    internal init(items: [PollSummaryItemRowViewModel]) {
        self.items = items
    }
}

class PollSummaryItemViewModel: ObservableObject, Identifiable {
    internal init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
    
    let title: String
    let subtitle: String
}

class PollSummaryItemRowViewModel: Identifiable {
    internal init(items: [PollSummaryItemViewModel]) {
        self.items = items
    }
    
    let items: [PollSummaryItemViewModel]
}

