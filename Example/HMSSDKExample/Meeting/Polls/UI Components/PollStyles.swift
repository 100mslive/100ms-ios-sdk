//
//  PollStyles.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    internal init(isWide: Bool = true) {
        self.isWide = isWide
    }
    
    var isWide: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HMSUIThemeCenter.sharedTheme.fonts.buttonSemibold1)
            .foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textAccentHighEmph)
            .frame(maxWidth: isWide ? .infinity : nil, alignment: .center)
            .padding(.vertical, 10)
            .padding(.horizontal, 24)
            .background(HMSUIThemeCenter.sharedTheme.colors.primaryDefault)
            .cornerRadius(8)
    }
}

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder).font(HMSUIThemeCenter.sharedTheme.fonts.body1Regular16)
                    .foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textDisabled)
                .padding(.horizontal, 0)
            }
            content
            .foregroundColor(Color.white)
        }
    }
}

struct HMSMainTextFieldStyle: TextFieldStyle {
    @Binding var focused: Bool
    var valid: Bool
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(valid ? HMSUIThemeCenter.sharedTheme.colors.surfaceLight : HMSUIThemeCenter.sharedTheme.colors.backgroundError)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(valid ? (focused ? HMSUIThemeCenter.sharedTheme.colors.primaryDefault : HMSUIThemeCenter.sharedTheme.colors.borderLight) : HMSUIThemeCenter.sharedTheme.colors.alertError , lineWidth: 1))
    }
}

struct HMSIconTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HMSUIThemeCenter.sharedTheme.fonts.body1Regular16)
            .foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textMediumEmph)
            .padding(12)
    }
}

struct ActionButtonLowEmphStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HMSUIThemeCenter.sharedTheme.fonts.buttonSemibold1)
            .foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textAccentHighEmph)
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
            .background(HMSUIThemeCenter.sharedTheme.colors.secondaryDefault)
            .cornerRadius(8)
    }
}
