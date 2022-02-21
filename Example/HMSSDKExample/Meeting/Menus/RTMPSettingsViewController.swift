//
//  RTMPSettingsViewController.swift
//  HMSSDKExample
//
//  Created by Dmitry Fedoseyev on 13.09.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK
import Eureka

protocol RTMPSettingsViewControllerDelegate: AnyObject {
    func rtmpSettingsController(_ rtmpSettingsController: RTMPSettingsViewController, didSelect config: HMSRTMPConfig)
}

final class RTMPSettingsViewController: FormViewController {

    internal weak var delegate: RTMPSettingsViewControllerDelegate?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Meeting URL")
            <<< URLRow("meetingURL") {
                $0.placeholder = "Meeting URL"
            }
        form +++ MultivaluedSection(multivaluedOptions: [.Insert, .Delete],
                                    header: "RTMP Urls",
                                    footer: "") {
            $0.addButtonProvider = { _ in
                return ButtonRow {
                    $0.title = "Add New RTMP URL"
                }
            }
            $0.multivaluedRowToInsertAt = { _ in
                return URLRow {
                    $0.placeholder = "RTMP URL"
                }
            }
            $0 <<< URLRow {
                $0.placeholder = "RTMP URL"
            }
            $0.tag = "rtmpURLs"
        }
        form +++ Section("")
            <<< SwitchRow("recordingSwitch") {
                $0.title = "Record"
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
        self.title = "RTMP Settings"
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Action Handlers

    private func onStartButtonTap() {

        let values = form.values()

        let meetingURL = values["meetingURL"] as? URL

        var rtmpURLs: [URL]?
        if let inputURLs = values["rtmpURLs"] as? [Any] {
            rtmpURLs = inputURLs.compactMap { $0 as? URL }
        }

        let recordingEnabled = (values["recordingSwitch"] as? Bool) ?? false

        let config = HMSRTMPConfig(meetingURL: meetingURL, rtmpURLs: rtmpURLs, record: recordingEnabled)
        delegate?.rtmpSettingsController(self, didSelect: config)
        navigationController?.popViewController(animated: true)
    }

    private func showNoTargetError() {
        let title = "Error"

        let alertController = UIAlertController(title: title,
                                                message: "Please select a target role",
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        present(alertController, animated: true)
    }
}
