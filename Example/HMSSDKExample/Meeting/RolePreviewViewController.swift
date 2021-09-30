//
//  RolePreviewViewController.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 21.09.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK

class RolePreviewViewController: PreviewViewController {
    var roleChangeRequest: HMSRoleChangeRequest!
    
    @IBOutlet private weak var changeRoleButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: changeRoleButton)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Preview Role"
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        interactor.hmsSDK?.preview(role: roleChangeRequest.suggestedRole, completion: { [weak self] tracks, error in
            guard error == nil else {
                self?.presentAlert(error?.description ?? "")
                return
            }
            self?.setupTracks(tracks: tracks ?? [])
        })
    }
    
    private func presentAlert(_ message: String) {
        let alertController = UIAlertController(title: "Error",
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        present(alertController, animated: true, completion: nil)
    }

    @IBAction private func changeRoleTapped(_ sender: UIButton) {
        interactor.hmsSDK?.accept(changeRole: roleChangeRequest, completion: { [weak self] success, error in
            self?.navigationController?.popViewController(animated: true)
        })
    }
}
