//
//  HMSDefaultUITheme.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI

struct HMSDefaultUITheme: HMSUITheme {
    var colors = HMSDefaultUIColorTheme()
    var fonts = HMSDefaultUIFontTheme()
}

struct HMSDefaultUIColorTheme: HMSUIColorTheme {
    var surfaceDefault = Color(UIColor(red: 0.075, green: 0.086, blue: 0.106, alpha: 1))
    var surfaceDark = Color(UIColor(red: 0.059, green: 0.067, blue: 0.082, alpha: 1))
    var surfaceLight = Color(UIColor(red: 0.118, green: 0.137, blue: 0.165, alpha: 1))
    var surfaceLighter = Color(UIColor(red: 0.157, green: 0.184, blue: 0.224, alpha: 1))
    
    var textHighEmph = Color(UIColor(red: 0.961, green: 0.976, blue: 1, alpha: 0.95))
    var textMediumEmph = Color(UIColor(red: 0.88, green: 0.926, blue: 1, alpha: 0.8))
    var textDisabled = Color(UIColor(red: 0.765, green: 0.816, blue: 0.898, alpha: 0.5))

    var textAccentHighEmph = Color(UIColor(red: 1, green: 1, blue: 1, alpha: 0.98))
    var textAccentMediumEmph = Color(UIColor(red: 1, green: 1, blue: 1, alpha: 0.72))
    var textAccentDisabled = Color(UIColor(red: 1, green: 1, blue: 1, alpha: 0.48))
    
    var borderDefault = Color(UIColor(red: 0.106, green: 0.122, blue: 0.149, alpha: 1))
    var borderLight = Color(UIColor(red: 0.176, green: 0.204, blue: 0.251, alpha: 1))
    var borderAccent = Color(UIColor(red: 0.149, green: 0.447, blue: 0.929, alpha: 1))
    
    var primaryDefault = Color(UIColor(red: 0.149, green: 0.447, blue: 0.929, alpha: 1))
    var secondaryDefault = Color(UIColor(red: 0.28, green: 0.326, blue: 0.4, alpha: 1))
    
    var alertError = Color(UIColor(red: 0.8, green: 0.322, blue: 0.373, alpha: 1))
    var alertSuccess = Color(UIColor(red: 0.212, green: 0.702, blue: 0.494, alpha: 1))
    
    var backgroundError = Color(UIColor(red: 0.125, green: 0.086, blue: 0.09, alpha: 1))
}

struct HMSDefaultUIFontTheme: HMSUIFontTheme {
    var captionRegular = Font(UIFont(name: "Inter-Regular", size: 12) ?? .systemFont(ofSize: 12))
    var body2Regular14 =  Font(UIFont(name: "Inter-Regular", size: 14) ?? .systemFont(ofSize: 14))
    var body1Regular16 =  Font(UIFont(name: "Inter-Regular", size: 16) ?? .systemFont(ofSize: 16))
    var body1Semibold16 =  Font(UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16))
    var subtitle1 =  Font(UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16))
    var subtitle2 =  Font(UIFont(name: "Inter-SemiBold", size: 14) ?? .systemFont(ofSize: 14))
    var buttonSemibold1 = Font(UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16))
    var overlineMedium =  Font(UIFont(name: "Inter-SemiBold", size: 10) ?? .systemFont(ofSize: 10))
    var heading6Semibold20 =  Font(UIFont(name: "Inter-SemiBold", size: 20) ?? .systemFont(ofSize: 20))
}
