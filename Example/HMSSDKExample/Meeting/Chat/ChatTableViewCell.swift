//
//  ChatTableViewCell.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 04/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

final class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var messageView: UITextView! {
        didSet {
            messageView.textContainer.lineFragmentPadding = 0
            messageView.textContainerInset = .zero
        }
    }
}
