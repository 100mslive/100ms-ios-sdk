//
//  HMSUIColorTheme.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI

protocol HMSUIColorTheme {
    var surfaceDefault: Color { get }
    var surfaceDark: Color { get }
    var surfaceLight: Color { get }
    var surfaceLighter: Color { get }
    
    var textHighEmph: Color { get }
    var textMediumEmph: Color { get }
    var textDisabled: Color { get }
    
    var textAccentHighEmph: Color { get }
    var textAccentMediumEmph: Color { get }
    var textAccentDisabled: Color { get }
    
    var borderDefault: Color { get }
    var borderLight: Color { get }
    var borderAccent: Color { get }
    
    var primaryDefault: Color { get }
    var secondaryDefault: Color { get }
    
    var alertError: Color { get }
    var alertSuccess: Color { get }
    
    var backgroundError: Color { get }
}
