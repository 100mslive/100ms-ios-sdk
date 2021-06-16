//
//  AppDelegate.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseInteractor()
        return true
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
    
    func meetingIDFromURL(_ url: URL) -> String? {
        var meetingID: String?
        var prevComponent = ""
        for component in url.pathComponents {
            if (prevComponent == "meeting" || prevComponent == "preview") {
                meetingID = component
            }
            prevComponent = component
        }
        
        return meetingID
    }
}
