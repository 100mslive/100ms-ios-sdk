//
//  ColorPickerView.swift
//  Procreate
//
//  Created by Pawan Dixit on 23/09/2022.
//

import SwiftUI

struct PickerControlView: View {
    
    let precisionFactor = 50.0
    
    // Params
    @Binding var controlValue: CGFloat
    @Binding var drawRefresh: Bool
    let onFinish: ((CGFloat)->Void)?
    
    let stripWidth: CGFloat
    let stripColors: [Color]
    let circleColor: Color
    
    // Gesture
    @State private var isDragging: Bool = false
    @State private var dragControlLocation: CGFloat = .zero
    @State private var dragOffset: CGSize = .zero
    
    // Gesture effects
    private var circleWidth: CGFloat {
        isDragging ? 35 : 15
    }
    
    // Normalize gesture between 0 and stripWidth
    private func normalizedGestureLocation() -> CGFloat {
        var gestureLocation = dragControlLocation + dragOffset.width
        
        // Normalize with respect to strip width
        gestureLocation = max(0, gestureLocation)
        gestureLocation = min(gestureLocation, stripWidth)
        
        return gestureLocation
    }
    
    // Current control value based on current translation within the view
    private var currentControlValue: CGFloat {
        self.normalizedGestureLocation() / stripWidth
    }
    
    @State var lastTranslation = CGSize.zero
    
    var body: some View {
        
        let dragGesture = DragGesture()
            .onChanged({ (value) in
                
                let translation = CGSize(width: value.translation.width - lastTranslation.width, height: value.translation.height - lastTranslation.height)
                
                lastTranslation = value.translation
                
                // Use drag in y axis as precision factor for x axis movement
                let yDrag = max(1, abs(value.translation.height)/precisionFactor)
                dragOffset = CGSize(width: translation.width/yDrag, height: value.translation.height)
                
                controlValue = currentControlValue
                
                self.dragControlLocation += self.dragOffset.width
                self.dragControlLocation = max(0, self.dragControlLocation)
                self.dragControlLocation = min(self.dragControlLocation, stripWidth)
                
                self.dragOffset = .zero
                
                withAnimation {
                    self.isDragging = true
                }
            })
            .onEnded({ (value) in
                
                lastTranslation = .zero
                
                onFinish?(self.controlValue)
                
                withAnimation {
                    
                    self.isDragging = false
                }
            })
        
        ZStack(alignment: .leading) {
            LinearGradient(gradient: Gradient(colors: stripColors),
                           startPoint: .leading,
                           endPoint: .trailing)
            .frame(width: stripWidth, height: 4)
            .cornerRadius(5)
            .shadow(radius: 8)
            
            Circle()
                .foregroundColor(self.circleColor)
                .frame(width: self.circleWidth, height: self.circleWidth, alignment: .center)
                .shadow(radius: 5)
                .offset(x: self.normalizedGestureLocation() - self.circleWidth / 2, y: 0.0)
                
            
        }
        .frame(width: stripWidth, height: 50)
        .padding(.horizontal)
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .onAppear() {
            dragControlLocation = controlValue * stripWidth
        }
        .onChange(of: drawRefresh) { newValue in
            dragControlLocation = controlValue * stripWidth
        }
    }
}

struct PickerControlView_Previews: PreviewProvider {
    static var previews: some View {
        PickerControlView(controlValue: .constant(0.5), drawRefresh: .constant(false), onFinish: nil, stripWidth: 600, stripColors: [.white, .red], circleColor: .red)
    }
}
