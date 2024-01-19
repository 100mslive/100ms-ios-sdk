//
//  HueStripView.swift
//  Procreate
//
//  Created by Pawan Dixit on 24/09/2022.
//

import SwiftUI

struct HueStripView: View {
    
    @Binding var controlValue: CGFloat
    let width: CGFloat
    @Binding var drawRefresh: Bool
    let onFinish: ((CGFloat)->Void)?
    
    private let gradientColors: [Color] = {
        let hueValues = Array(0...359).reversed()
        return hueValues.map {
            Color(UIColor(hue: CGFloat($0) / 359.0 ,
                          saturation: 1.0,
                          brightness: 1.0,
                          alpha: 1.0))
        }
    }()
    
    var body: some View {
        
        let controlColor = Color(UIColor.init(hue: 1.0 - controlValue, saturation: 1.0, brightness: 1.0, alpha: 1.0))
                                 
        PickerControlView(controlValue: $controlValue, drawRefresh: $drawRefresh, onFinish: onFinish, stripWidth: width, stripColors: gradientColors, circleColor: controlColor)
    }
}

struct HueStripView_Previews: PreviewProvider {
    static var previews: some View {
        HueStripView(controlValue: .constant(1), width: 600, drawRefresh: .constant(true), onFinish: nil)
    }
}
