//
//  Utilities.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import QuartzCore

final class Utilities {

    class func drawCorner(on view: UIView) {
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
    }

    class func applyBorder(on view: UIView, skipColor: Bool = false) {
        if !skipColor {
            view.layer.borderColor = UIColor(named: "Border")?.cgColor
            view.layer.borderWidth = 1
        }
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
    }

    class func applySpeakingBorder(on view: UIView) {
        view.layer.borderColor = UIColor.link.cgColor
        view.layer.borderWidth = 4
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
    }

    class func getAvatarName(from name: String) -> String {
        let words = name.components(separatedBy: " ")

        var avatar = ""

        for (index, word) in words.enumerated() where index < 2 {
            if let character = word.first {
                avatar += "\(character)"
            }
        }

        if avatar.count == 1 {
            let trimmedName = "\(name.dropFirst())"
            if let nextCharacter = trimmedName.first {
                avatar += "\(nextCharacter)"
            }
        }

        return avatar.uppercased()
    }

    class func showToast(message: String, removeAfter: Int = 0) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              window.subviews.first(where: { $0.tag == 101 }) == nil
              else { return }

        let view = UIView(frame: CGRect(x: window.frame.size.width/2 - 170,
                                        y: window.frame.size.height - 200,
                                        width: 340, height: 35))
        view.tag = 101
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        view.layer.masksToBounds = true
        window.addSubview(view)
        window.bringSubviewToFront(view)

        let label = UILabel(frame: view.bounds)
        label.textColor = .link
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        label.text = message
        label.tag = 101
        view.addSubview(label)

        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.clipsToBounds = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(removeAfter)) {
            UIView.animate(withDuration: 4, delay: 0.1, options: .transitionCrossDissolve, animations: {
                view.alpha = 0.0
            }, completion: { _ in
                view.removeFromSuperview()
            })
        }
    }
}

protocol ErrorProtocol: LocalizedError {
    var title: String { get }
    var code: Int? { get }
    var localizedDescription: String { get }
}

enum Layout {
    case grid, portrait
}

enum VideoCellState {
    case insert(index: Int)
    case delete(index: Int)
    case refresh(indexes: (Int, Int))
}

extension UIImageView {
    func rotate() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 2.5
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }

    func hide() {
        UIView.animate(withDuration: 0.7, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
        })
    }
}

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

struct Orientation {
    // indicate current device is in the LandScape orientation
    static var isLandscape: Bool {
        UIDevice.current.orientation.isValidInterfaceOrientation
            ? UIDevice.current.orientation.isLandscape
            : (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape)!
    }
    // indicate current device is in the Portrait orientation
    static var isPortrait: Bool {
        UIDevice.current.orientation.isValidInterfaceOrientation
            ? UIDevice.current.orientation.isPortrait
            : (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isPortrait)!
    }
}

extension UIView {
    func addConstrained(subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
