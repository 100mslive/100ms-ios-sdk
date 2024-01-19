//
//  BrightnessStripView.swift
//  Procreate
//
//  Created by Pawan Dixit on 24/09/2022.
//

import SwiftUI

struct BrightnessStripView: View {
    
    @Binding var controlValue: CGFloat
    let width: CGFloat
    @Binding var drawRefresh: Bool
    let onFinish: ((CGFloat)->Void)?
    
    var body: some View {
        
        let controlColor = Color(UIColor.init(hue: 0.0, saturation: 0.0, brightness: controlValue, alpha: 1.0))
        
        PickerControlView(controlValue: $controlValue, drawRefresh: $drawRefresh, onFinish: onFinish, stripWidth: width, stripColors: extremeEndColors, circleColor: controlColor)
    }
    
    private var extremeEndColors: [Color] {
        [Color(UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0, alpha: 1.0)),
         Color(UIColor.init(hue: 0.0, saturation: 0.0, brightness: 1, alpha: 1.0))]
    }
}

struct BrightnessStripView_Previews: PreviewProvider {
    static var previews: some View {
        BrightnessStripView(controlValue: .constant(1), width: 600, drawRefresh: .constant(true), onFinish: nil)
    }
}
