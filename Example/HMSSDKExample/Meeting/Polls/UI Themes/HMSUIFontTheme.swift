//
//  HMSUIFontTheme.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI

protocol HMSUIFontTheme {
    var captionRegular: Font { get }
    var body2Regular14: Font { get }
    var body1Regular16: Font { get }
    var body1Semibold16: Font { get }
    var subtitle1: Font { get }
    var subtitle2: Font { get }
    var buttonSemibold1: Font { get }
    var overlineMedium: Font { get }
    var heading6Semibold20: Font { get }
}
