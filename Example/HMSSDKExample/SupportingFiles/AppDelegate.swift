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

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
              let host = components.host,
              var meetingID = incomingURL.pathComponents.last else {
            print(#function, "Error: Could not get correct URL!")
            return false
        }

        if !meetingID.isAlphanumeric {
            for component in incomingURL.pathComponents.reversed() where component.isAlphanumeric {
                meetingID = component
                break
            }
        }

        let userInfo = [ Constants.roomIDKey: meetingID,
                         Constants.hostKey: host ]

        NotificationCenter.default.post(name: Constants.deeplinkTapped,
                                        object: nil,
                                        userInfo: userInfo)

        return true
    }
}
