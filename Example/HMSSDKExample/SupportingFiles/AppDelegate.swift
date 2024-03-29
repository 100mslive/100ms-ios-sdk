//
//  AppDelegate.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import SwiftyBeaver

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupLogging()
        UserDefaults.standard.set(false, forKey: Constants.enableOrientationLock)
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if UserDefaults.standard.bool(forKey: Constants.enableOrientationLock) {
            return .landscape
        }
        else {
            return .all
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if let window = window {
            let view = UIView(frame: window.frame)
            view.backgroundColor = .black
            view.tag = 1
            window.rootViewController?.view.addSubview(view)
            window.rootViewController?.view.bringSubviewToFront(view)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if let view = window?.rootViewController?.view.subviews.first(where: { $0.tag == 1 }) {
            view.removeFromSuperview()
        }
    }
    
    private func setupLogging() {
        let log = SwiftyBeaver.self
        let console = ConsoleDestination()
        let file = FileDestination(logFileURL: Constants.logFileURL)
        file.logFileAmount = 2
        log.addDestination(console)
        log.addDestination(file)
    }
    
}
