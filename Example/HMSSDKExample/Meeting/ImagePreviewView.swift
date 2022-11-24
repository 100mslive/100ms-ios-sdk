//
//  ImagePreviewView.swift
//  HMSSDKExample
//
//  Created by Pawan Dixit on 09/11/2022.
//  Copyright © 2022 100ms. All rights reserved.
//

import SwiftUI

struct ImagePreviewView: View {
    
    let image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
