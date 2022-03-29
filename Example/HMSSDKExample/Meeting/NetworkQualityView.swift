//
//  NetworkQualityView.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.03.2022.
//  Copyright © 2022 100ms. All rights reserved.
//

import UIKit

class NetworkQualityView: UIView {
    let imageView: UIImageView
    
    var quality: Int = 0 {
        didSet {
            var level = 1
            isHidden = false
            
            if quality < 1 {
                isHidden = true
            } else if quality < 5 {
                level = quality
            } else {
                level = 4
            }
            let imageName = "Level=\(level)"
            imageView.image = UIImage(named: imageName)
        }
    }
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        super.init(frame: frame)
        
        backgroundColor = .clear
        addSubview(imageView)
        imageView.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        imageView = UIImageView()
        super.init(coder: coder)

        backgroundColor = .clear
        addSubview(imageView)
        imageView.frame = self.bounds
    }

}
