//
//  ColorControlsView.swift
//  HMSSDKExample
//
//  Created by Pawan Dixit on 1/9/24.
//  Copyright © 2024 100ms. All rights reserved.
//

import SwiftUI
import HMSSDK

struct ColorControlsView: View {
    
    let videoFilterPlugin: HMSVideoFilterPlugin
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var drawRefresh = false
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                .edgesIgnoringSafeArea(.all)
                .opacity(0.01)
            
            VStack(alignment: .center) {
                
                Button {
                    videoFilterPlugin.brightness = HMSVideoFilterPlugin.defaultBrightness
                    videoFilterPlugin.saturation = HMSVideoFilterPlugin.defaultSaturation
                    videoFilterPlugin.hue = HMSVideoFilterPlugin.defaultHue
                    videoFilterPlugin.sharpness = HMSVideoFilterPlugin.defaultSharpness
                    videoFilterPlugin.redness = HMSVideoFilterPlugin.defaultRedness
                    videoFilterPlugin.smoothness = HMSVideoFilterPlugin.defaultSmoothness
                    
                    drawRefresh.toggle()
                } label: {
                    Text("Reset")
                }
                
                VStack(spacing: 5) {
                    HueStripView(controlValue: Binding(get: {
                        videoFilterPlugin.hue
                    }, set: {
                        videoFilterPlugin.hue = $0
                    }), width: 300, drawRefresh: $drawRefresh, onFinish: {_ in
                    })
                    Text("Hue")
                        
                }
                
                VStack(spacing: 5) {
                    SaturationStripView(controlValue: Binding(get: {
                        videoFilterPlugin.saturation
                    }, set: {
                        videoFilterPlugin.saturation = $0
                    }), width: 300, drawRefresh: $drawRefresh, onFinish: {_ in
                    })
                    Text("Saturation")
                        
                }
                
                VStack(spacing: 5) {
                    BrightnessStripView(controlValue: Binding(get: {
                        videoFilterPlugin.brightness
                    }, set: {
                        videoFilterPlugin.brightness = $0
                    }), width: 300, drawRefresh: $drawRefresh, onFinish: {_ in
                    })
                    Text("Brightness")
                       
                }
                
                VStack(spacing: 5) {
                    BrightnessStripView(controlValue: Binding(get: {
                        videoFilterPlugin.sharpness
                    }, set: {
                        videoFilterPlugin.sharpness = $0 * 1
                    }), width: 300, drawRefresh: $drawRefresh, onFinish: {_ in
                    })
                    Text("Sharpness")
                        
                }
                
                VStack(spacing: 5) {
                    BrightnessStripView(controlValue: Binding(get: {
                        videoFilterPlugin.redness - 1
                    }, set: {
                        videoFilterPlugin.redness = 1 + $0
                    }), width: 300, drawRefresh: $drawRefresh, onFinish: {_ in
                    })
                    Text("Redness")
                        
                }
                
                VStack(spacing: 5) {
                    BrightnessStripView(controlValue: Binding(get: {
                        videoFilterPlugin.smoothness
                    }, set: {
                        videoFilterPlugin.smoothness = $0 * 1
                    }), width: 300, drawRefresh: $drawRefresh, onFinish: {_ in
                    })
                    Text("Smoothness")
                        
                }
                
                VStack(spacing: 5) {
                    BrightnessStripView(controlValue: Binding(get: {
                        videoFilterPlugin.exposure
                    }, set: {
                        videoFilterPlugin.exposure = $0
                    }), width: 300, drawRefresh: $drawRefresh, onFinish: {_ in
                    })
                    Text("Exposure")
                        
                }
            }
            .foregroundColor(.white)
            .padding()
        }
        .onTapGesture {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
