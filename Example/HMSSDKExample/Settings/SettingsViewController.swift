//
//  SettingsViewController.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 27/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - View Properties

    let defaultVideoSource = ["Front Facing", "Rear Facing"]
    let availableAudioSources = AudioSourceType.allCases

    @IBOutlet weak var videoSourcePicker: UIPickerView!

    @IBOutlet weak var audioSourcePicker: UIPickerView!
    
    @IBOutlet weak var videoResolutionPicker: UIPickerView!

    @IBOutlet weak var videoBitRatePicker: UIPickerView!

    @IBOutlet weak var publishVideoSwitch: UISwitch! {
        didSet {
            publishVideoSwitch.isOn = UserDefaults.standard.publishVideo
        }
    }

    @IBOutlet weak var publishAudioSwitch: UISwitch! {
        didSet {
            publishAudioSwitch.isOn = UserDefaults.standard.publishAudio
        }
    }

    @IBOutlet weak var mirrorMyVideoSwitch: UISwitch! {
        didSet {
            let isOn = UserDefaults.standard.object(forKey: Constants.mirrorMyVideo) as? Bool ?? true
            mirrorMyVideoSwitch.setOn(isOn, animated: false)
        }
    }

    @IBOutlet weak var showVideoPreviewSwitch: UISwitch! {
        didSet {
            let isOn = UserDefaults.standard.object(forKey: Constants.showVideoPreview) == nil || UserDefaults.standard.bool(forKey: Constants.showVideoPreview)
            
            showVideoPreviewSwitch.setOn(isOn, animated: false)
        }
    }

    @IBOutlet weak var showStatsSwitch: UISwitch! {
        didSet {
            if let isOn = UserDefaults.standard.object(forKey: Constants.showStats) as? Bool {
                showStatsSwitch.setOn(isOn, animated: false)
            }
        }
    }
    @IBOutlet weak var testModeSwitch: UISwitch! {
        didSet {
            if let isOn = UserDefaults.standard.object(forKey: Constants.testMode) as? Bool {
                testModeSwitch.setOn(isOn, animated: false)
            }
        }
    }
    @IBOutlet weak var lockOrientationSwitch: UISwitch! {
        didSet {
            if let isOn = UserDefaults.standard.object(forKey: Constants.enableOrientationLock) as? Bool {
                lockOrientationSwitch.setOn(isOn, animated: false)
            }
        }
    }
    
    @IBOutlet weak var autoSimulcastLayerSelectionSwitch: UISwitch! {
        didSet {
            let isOn = UserDefaults.standard.object(forKey: Constants.autoSimulcastLayerSelection) as? Bool ?? true
            autoSimulcastLayerSelectionSwitch.setOn(isOn, animated: false)
        }
    }

   
    @IBOutlet weak var disablePiPSSwitch: UISwitch! {
        didSet {
            let shouldDisablePiP = UserDefaults.standard.object(forKey: Constants.disablePiP) as? Bool ?? false
            disablePiPSSwitch.setOn(shouldDisablePiP, animated: false)
        }
    }
    
    @IBOutlet weak var appVersionLabel: UILabel! {
        didSet {
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
               let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
                appVersionLabel.text = version + " " + "(" + build + ")"
            }
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPickers()
    }

    // MARK: - View Modifiers

    func setupPickers() {

        let userDefaults = UserDefaults.standard

        let videoSource = userDefaults.string(forKey: Constants.defaultVideoSource) ?? "Front Facing"
        let videoSourceIndex = defaultVideoSource.firstIndex(of: videoSource) ?? 0
        videoSourcePicker.selectRow(videoSourceIndex, inComponent: 0, animated: false)
        
        let audioSource = AudioSourceType(rawValue: userDefaults.integer(forKey: Constants.defaultAudioSource)) ?? .audioMixer
        let audioSourceIndex = availableAudioSources.firstIndex(of: audioSource) ?? 0
        audioSourcePicker.selectRow(audioSourceIndex, inComponent: 0, animated: false)
    }

    // MARK: - Action Handlers

    @IBAction func closeTapped(_ sender: UIButton) {
        save()
        NotificationCenter.default.post(name: Constants.settingsUpdated, object: nil)
        self.dismiss(animated: true)
    }

    func save() {
        let userDefaults = UserDefaults.standard

        userDefaults.publishVideo = publishVideoSwitch.isOn
        userDefaults.publishAudio = publishAudioSwitch.isOn
        userDefaults.set(mirrorMyVideoSwitch.isOn, forKey: Constants.mirrorMyVideo)
        userDefaults.set(showVideoPreviewSwitch.isOn, forKey: Constants.showVideoPreview)
        userDefaults.set(showStatsSwitch.isOn, forKey: Constants.showStats)
        userDefaults.set(testModeSwitch.isOn, forKey: Constants.testMode)
        userDefaults.set(lockOrientationSwitch.isOn, forKey: Constants.enableOrientationLock)
        userDefaults.set(autoSimulcastLayerSelectionSwitch.isOn, forKey: Constants.autoSimulcastLayerSelection)
        userDefaults.set(disablePiPSSwitch.isOn, forKey: Constants.disablePiP)

        let videoSource = defaultVideoSource[videoSourcePicker.selectedRow(inComponent: 0)]
        userDefaults.set(videoSource, forKey: Constants.defaultVideoSource)
        
        let audioSource = availableAudioSources[audioSourcePicker.selectedRow(inComponent: 0)]
        userDefaults.set(audioSource.rawValue, forKey: Constants.defaultAudioSource)

    }
}

// MARK: - Picker View

extension SettingsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return defaultVideoSource.count
        case 1:
            return availableAudioSources.count
        default:
            return 0
        }
    }
}

extension SettingsViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        switch pickerView.tag {
        case 0:
            return defaultVideoSource[row]
        case 1:
            return availableAudioSources[row].description
        default:
            return nil
        }
    }
}
