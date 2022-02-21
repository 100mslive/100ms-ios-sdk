//
//  HLSSettingsViewController.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 10.12.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK
import Eureka

protocol HLSSettingsViewControllerDelegate: AnyObject {
    func hlsSettingsController(_ hlsSettingsController: HLSSettingsViewController, didSelect config: HMSHLSConfig)
}

final class HLSSettingsViewController: FormViewController {

    internal weak var delegate: HLSSettingsViewControllerDelegate?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Meeting URL")
            <<< URLRow("meetingURL") {
                $0.placeholder = "Meeting URL"
            }
        form +++ Section("")
            <<< ButtonRow {
                $0.title = "Start"
                $0.onCellSelection { [weak self] _, _ in
                    self?.onStartButtonTap()
                }
            }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "HLS Settings"
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Action Handlers

    private func onStartButtonTap() {

        let values = form.values()

        guard let meetingURL = values["meetingURL"] as? URL else {
            return
        }

        let config = HMSHLSConfig(variants: [HMSHLSMeetingURLVariant(meetingURL: meetingURL, metadata: "main stream")])
        delegate?.hlsSettingsController(self, didSelect: config)
        navigationController?.popViewController(animated: true)
    }
}
