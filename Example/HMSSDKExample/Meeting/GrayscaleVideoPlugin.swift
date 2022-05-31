//
//  GrayscaleVideoPlugin.swift
//  HMSSDKExample
//
//  Created by Pawan Dixit on 16/04/22.
//  Copyright © 2022 100ms. All rights reserved.
//

import Foundation
import HMSSDK

class GrayscaleVideoPlugin: HMSVideoPlugin {
    
    static let defaultAttributes: [NSString: NSObject] = [
        kCVPixelBufferPixelFormatTypeKey: NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
        kCVPixelBufferIOSurfacePropertiesKey : [:] as NSDictionary
    ]
    
    private var attributes: [NSString: NSObject] {
        var attributes: [NSString: NSObject] = Self.defaultAttributes
        attributes[kCVPixelBufferWidthKey] = NSNumber(value: Int(extent.width))
        attributes[kCVPixelBufferHeightKey] = NSNumber(value: Int(extent.height))
        return attributes
    }
    
    private var _pixelBufferPool: CVPixelBufferPool?
    private var pixelBufferPool: CVPixelBufferPool! {
        get {
            if _pixelBufferPool == nil {
                var pixelBufferPool: CVPixelBufferPool?
                CVPixelBufferPoolCreate(nil, nil, attributes as CFDictionary?, &pixelBufferPool)
                _pixelBufferPool = pixelBufferPool
            }
            return _pixelBufferPool!
        }
        set {
            _pixelBufferPool = newValue
        }
    }
    
    private var extent = CGRect.zero {
        didSet {
            guard extent != oldValue else { return }
            pixelBufferPool = nil
        }
    }
    
    let ciContext = CIContext(options: nil)
    
    override func process(_ frame: CVPixelBuffer) -> CVPixelBuffer {
        let inputImage = CIImage(cvPixelBuffer: frame)
        
        guard let outputImage = inputImage.grayscale else { return frame }
        
        var outputBuffer: CVImageBuffer?
        
        extent = outputImage.extent
        
        CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &outputBuffer)

        if let outputBuffer = outputBuffer {
            ciContext.render(outputImage, to: outputBuffer)
        }
        return outputBuffer ?? frame
    }
}

extension CIImage {
    var grayscale: CIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(self, forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return CIImage(cgImage: cgImage)
        }
        return nil
    }
}
