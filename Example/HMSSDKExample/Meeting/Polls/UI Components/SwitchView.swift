//
//  SwitchView.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI

struct SwitchView: View {
    @State var text: String
    @Binding var isOn: Bool
     
    var body: some View {
        HStack(spacing: 12) {
            Toggle("", isOn: $isOn).labelsHidden().toggleStyle(SwitchToggleStyle(tint: HMSUIThemeCenter.sharedTheme.colors.primaryDefault))
            Text(text).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14).frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
