//
//  PollTypeButton.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI

struct PollTypeButton: View {
    var text: String
    var icon: String
    var selected: Bool
    var action: (()->Void)
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).frame(width: 32, height: 32).padding(8).overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(selected ? HMSUIThemeCenter.sharedTheme.colors.borderAccent : HMSUIThemeCenter.sharedTheme.colors.borderLight, lineWidth: 1)
                ).background(HMSUIThemeCenter.sharedTheme.colors.surfaceLight)
                Text(text).font(HMSUIThemeCenter.sharedTheme.fonts.subtitle1).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).frame(maxWidth: .infinity, alignment: .leading).padding([.leading], 8)
            }.padding(8).overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selected ? HMSUIThemeCenter.sharedTheme.colors.borderAccent : HMSUIThemeCenter.sharedTheme.colors.borderLight, lineWidth: 1)
            )
        }
    }
}
