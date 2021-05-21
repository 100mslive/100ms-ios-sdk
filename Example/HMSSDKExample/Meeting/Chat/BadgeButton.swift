//
//  BadgeButton.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 01/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

final class BadgeButton: UIButton {

    var badgeLabel = UILabel()

    var badge: String? {
        didSet {
            addBadgeToButon(badge: badge)
        }
    }

    public var badgeBackgroundColor = UIColor.red {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }

    public var badgeTextColor = UIColor.white {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }

    public var badgeFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            badgeLabel.font = badgeFont
        }
    }

    public var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            addBadgeToButon(badge: badge)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addBadgeToButon(badge: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addBadgeToButon(badge: nil)
    }

    func addBadgeToButon(badge: String?) {
        badgeLabel.text = badge
        badgeLabel.textColor = badgeTextColor
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.font = badgeFont
        badgeLabel.sizeToFit()
        badgeLabel.textAlignment = .center
        let badgeSize = badgeLabel.frame.size

        let height = max(18, Double(badgeSize.height) + 5.0)
        let width = max(height, Double(badgeSize.width) + 10.0)

        var vertical: Double?, horizontal: Double?
        if let badgeInset = self.badgeEdgeInsets {
            vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
            horizontal = Double(badgeInset.left) - Double(badgeInset.right)

            let xAxis = (Double(bounds.size.width) - 10 + horizontal!)
            let yAxis = -(Double(badgeSize.height) / 2) - 10 + vertical!
            badgeLabel.frame = CGRect(x: xAxis, y: yAxis, width: width, height: height)
        } else {
            let xAxis = self.frame.width - CGFloat(width*1.5)
            let yAxis = CGFloat(-(height*0.25))
            badgeLabel.frame = CGRect(x: xAxis, y: yAxis, width: CGFloat(width), height: CGFloat(height))
        }

        badgeLabel.layer.cornerRadius = badgeLabel.frame.height/2
        badgeLabel.layer.masksToBounds = true
        addSubview(badgeLabel)
        badgeLabel.isHidden = badge != nil ? false : true
    }
}
