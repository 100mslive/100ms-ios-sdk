//
//  HMSUIThemeCenter.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.06.2023.
//  Copyright © 2023 100ms. All rights reserved.
//

import Foundation

struct HMSUIThemeCenter {
    static var sharedTheme: any HMSUITheme = HMSDefaultUITheme()
}

protocol HMSUITheme {
    associatedtype Colors: HMSUIColorTheme
    associatedtype Fonts: HMSUIFontTheme
    var colors: Colors { get }
    var fonts: Fonts { get }
}
