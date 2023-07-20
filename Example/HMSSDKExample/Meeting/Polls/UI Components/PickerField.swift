//
//  PickerField.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import SwiftUI

struct HMSPickerField: View {
    @State var title: String
    @State var options: [String]
    @Binding var selectedOption: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title).foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph).font(HMSUIThemeCenter.sharedTheme.fonts.body2Regular14)
            }
            HStack {
                Menu {
                    Picker(selection: $selectedOption) {
                        ForEach(options, id: \.self) { option in
                            Text(option)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(HMSUIThemeCenter.sharedTheme.fonts.body1Regular16)
                                .foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph)
                        }
                    } label: {}
                } label: {
                    Text(selectedOption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(HMSUIThemeCenter.sharedTheme.fonts.body1Regular16)
                        .foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph)
                    
                }
                Image(systemName: "chevron.down").foregroundColor(HMSUIThemeCenter.sharedTheme.colors.textHighEmph)
            }
            .padding(16)
            .background(HMSUIThemeCenter.sharedTheme.colors.surfaceLight)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(HMSUIThemeCenter.sharedTheme.colors.borderLight, lineWidth: 1))
        }
    }
}
