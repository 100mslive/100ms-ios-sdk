//
//  FirebaseInteractor.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 04/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import Firebase

final class FirebaseInteractor {

    @discardableResult init() {

        FirebaseApp.configure()

        #if targetEnvironment(simulator)
        // don't check for updates
        #else
        checkForUpdate()
        #endif
    }

    private func checkForUpdate() {

        AppDistribution.appDistribution().checkForUpdate(completion: { release, _ in
            guard let release = release else {
                return
            }

            let title = "New Version \(release.displayVersion)(\(release.buildVersion)) is available! 🎉"
            let message = release.releaseNotes
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.default) { _ in
                UIApplication.shared.open(release.downloadURL)
            })

            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))

            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
        })
    }
}
