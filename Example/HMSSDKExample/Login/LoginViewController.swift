//
//  LoginViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import SwiftyGif

final class LoginViewController: UIViewController {

    // MARK: - View Properties
    @IBOutlet weak var hmsGif: UIImageView! {
        didSet {
            do {
                let gif = try UIImage(gifName: "100ms.gif")
                let imageview = UIImageView(gifImage: gif, loopCount: -1)
                imageview.frame = hmsGif.bounds
                hmsGif.addSubview(imageview)
                Utilities.drawCorner(on: hmsGif)
            } catch {
                print(error)
            }
        }
    }

    @IBOutlet private weak var settingsButton: UIButton!

    @IBOutlet private weak var containerStackView: UIStackView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
            containerStackView.addGestureRecognizer(tap)
        }
    }

    @IBOutlet private weak var joinMeetingIDField: UITextField! {
        didSet {
            Utilities.drawCorner(on: joinMeetingIDField)
        }
    }

    @IBOutlet private weak var joinMeetingStackView: UIStackView! {
        didSet {
            Utilities.drawCorner(on: joinMeetingStackView)
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = joinMeetingStackView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            joinMeetingStackView.addSubview(blurEffectView)
            joinMeetingStackView.sendSubviewToBack(blurEffectView)
        }
    }

    @IBOutlet private weak var joinMeetingButton: UIButton! {
        didSet {
            Utilities.drawCorner(on: joinMeetingButton)
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        observeNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        joinMeetingIDField.text = UserDefaults.standard.string(forKey: Constants.roomIDKey) ?? Constants.defaultRoomID
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {

        super.willTransition(to: newCollection, with: coordinator)

        coordinator.animate { _ in
            self.joinMeetingIDField.resignFirstResponder()
        }
    }

    // MARK: - View Modifiers

    private func observeNotifications() {
        _ = NotificationCenter.default.addObserver(forName: Constants.deeplinkTapped,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in
            guard let info = notification.userInfo,
                  let roomID = info[Constants.roomIDKey] as? String,
                  let strongSelf = self,
                  !strongSelf.checkIfInMeeting()
            else {
                print(#function, "Error: Could not find correct Deep link URL")
                return
            }

            self?.joinMeetingIDField.text = roomID

            self?.showInputAlert()
        }

    }

    private func checkIfInMeeting() -> Bool {
        if let controllers = navigationController?.viewControllers {
            for controller in controllers {
                if controller.isKind(of: PreviewViewController.self) ||
                    controller.isKind(of: MeetingViewController.self) {
                    return true
                }
            }
        }
        return false
    }

    private func save(_ name: String, _ room: String, _ meeting: String? = nil) {
        let userDefaults = UserDefaults.standard

        userDefaults.set(name, forKey: Constants.defaultName)
        userDefaults.set(room, forKey: Constants.roomIDKey)

        if let meeting = meeting {
            userDefaults.set(meeting, forKey: "meeting")
        }
    }

    // MARK: - Action Handlers

    @objc private func dismissKeyboard(_ sender: Any) {
        joinMeetingIDField.resignFirstResponder()
    }

    @IBAction private func startMeetingTapped(_ sender: UIButton) {

        showInputAlert()
    }

    private func showInputAlert() {

        let title = "Join a Meeting"
        let action = "Join"

        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Enter your Name"
            textField.clearButtonMode = .always
            textField.text =  UserDefaults.standard.string(forKey: Constants.defaultName)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: action, style: .default) { [weak self] _ in
            self?.handleActions(for: alertController)
        })

        present(alertController, animated: true)
    }

    private func handleActions(for alertController: UIAlertController) {
        var room: String

        if !joinMeetingIDField.text!.isEmpty {
            room = joinMeetingIDField.text!
        } else {
            showErrorAlert(with: "Enter Meeting ID!")
            return
        }

        guard let name = alertController.textFields?[0].text, !name.isEmpty,
              let viewController = self.storyboard?.instantiateViewController(identifier: Constants.previewControllerIdentifier) as? PreJoinPreviewViewController
        else {
            dismiss(animated: true)
            let message = "Enter Name!"
            showErrorAlert(with: message)
            return
        }

        viewController.user = name
        viewController.roomName = room

        save(name, room)

        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showErrorAlert(with message: String) {
        let alertController = UIAlertController(title: "Alert",
                                                message: message,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        present(alertController, animated: true, completion: nil)
    }

    @IBAction private func settingsTapped(_ sender: UIButton) {
        guard let viewController = UIStoryboard(name: Constants.settings, bundle: nil)
                .instantiateInitialViewController() as? SettingsViewController
        else {
            return
        }

        present(viewController, animated: true)
    }
}
