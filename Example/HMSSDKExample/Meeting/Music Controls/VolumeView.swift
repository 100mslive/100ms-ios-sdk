//
//  VolumeView.swift
//  HMSSDKExample
//
//  Created by Pawan Dixit on 04/07/22.
//  Copyright © 2022 100ms. All rights reserved.
//

import SwiftUI

struct VolumeView: View {
    
    @State var maxHeight: CGFloat = UIScreen.main.bounds.height / 3
    @Binding var sliderProgress: CGFloat
    @State var sliderHeight: CGFloat = 0
    @State var lastDragValue: CGFloat = 0
    
    var body: some View {
        ZStack(alignment:.bottom, content: {
            Rectangle()
                .fill(Color.white.opacity(0.15))
            
            Rectangle()
                .fill(Color.white)
                .frame(height: sliderHeight)
        })
        .onAppear() {
            sliderHeight = sliderProgress * maxHeight
            lastDragValue = sliderHeight
        }
        .frame(width: 100, height: maxHeight)
        .cornerRadius(35)
        .gesture (
            DragGesture (minimumDistance:0)
                .onChanged ({ (value) in
                    let translation = value.translation
                    sliderHeight = -translation.height + lastDragValue
                    sliderHeight = sliderHeight > maxHeight ? maxHeight : sliderHeight
                    sliderHeight = sliderHeight >= 0 ? sliderHeight : 0
                    
                    let progress = sliderHeight / maxHeight
                    
                    sliderProgress = progress <= 1.0 ? progress : 1
        }).onEnded ({ (value) in
            sliderHeight = sliderHeight > maxHeight ? maxHeight : sliderHeight
            sliderHeight = sliderHeight >= 0 ? sliderHeight : 0
            lastDragValue = sliderHeight
        }))
    }
}
