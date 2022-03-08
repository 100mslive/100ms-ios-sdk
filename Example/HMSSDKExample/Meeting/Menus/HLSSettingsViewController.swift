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
        form +++ Section("Recording")
            <<< SwitchRow("recordingLayerSwitch") {
                $0.title = "Single file per layer"
            }
            <<< SwitchRow("recordingVODSwitch") {
                $0.title = "Enable VOD"
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

        let singleFile = (values["recordingLayerSwitch"] as? Bool) ?? false
        let vod = (values["recordingVODSwitch"] as? Bool) ?? false

        var recordConfig: HMSHLSRecordingConfig? = nil
        if singleFile || vod {
            recordConfig = HMSHLSRecordingConfig(singleFilePerLayer: singleFile, enableVOD: vod)
        }

        let variant = HMSHLSMeetingURLVariant(meetingURL: meetingURL, metadata: "main stream")
        let config = HMSHLSConfig(variants: [variant], recording: recordConfig)
        delegate?.hlsSettingsController(self, didSelect: config)
        navigationController?.popViewController(animated: true)
    }
}
