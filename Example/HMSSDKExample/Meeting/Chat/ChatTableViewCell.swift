//
//  ChatTableViewCell.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 04/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK

final class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var delegate: ChatViewController?

    @IBOutlet weak var messageView: UITextView! {
        didSet {
            messageView.textContainer.lineFragmentPadding = 0
            messageView.textContainerInset = .zero
        }
    }
    
    @IBOutlet weak var msgOptionsMenuButton: UIButton! {
        
        didSet {
            if #available(iOS 14.0, *) {
                msgOptionsMenuButton.menu = menu
                msgOptionsMenuButton.showsMenuAsPrimaryAction = true
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    var menu: UIMenu {
        UIMenu(title: "Options", children: menuItems)
    }

    var menuItems: [UIAction] {

        let result = [
            UIAction(title: "Pin", image: UIImage(systemName: "pin")) { [weak self] _ in
                
                guard let self = self else { return }
                
                let pinnedChatText = (self.nameLabel.text ?? "NA") + ": " + self.messageView.text
                
                self.delegate?.interactor?.setPinnedMessage(pinnedChatText) { _, error in
                    if let error = error as? HMSError {
                        self.delegate?.showActionError(error, action: "pin chat")
                    }
                }
            }
        ]

        return result
    }
}
