//
//  LoginViewController.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit
import SwiftyGif
import HMSSDK

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
    
    private var collectFeedbackOnAppear = false

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
    
    var shouldShowPreview: Bool {
        UserDefaults.standard.object(forKey: Constants.showVideoPreview) == nil || UserDefaults.standard.bool(forKey: Constants.showVideoPreview)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        observeNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        joinMeetingIDField.text = UserDefaults.standard.string(forKey: Constants.roomIDKey)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (collectFeedbackOnAppear) {
            collectFeedbackOnAppear = false
            collectFeedback()
        }
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

        NotificationCenter.default.addObserver(forName: Constants.meetingLeft,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            self?.collectFeedbackOnAppear = true
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

        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Enter your Name"
            textField.clearButtonMode = .always
            textField.text =  UserDefaults.standard.string(forKey: Constants.defaultName)
            textField.accessibilityIdentifier = "login-popup-enter-name-textfield"
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Join", style: .default) { [weak self] _ in
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

        guard let name = alertController.textFields?[0].text, !name.isEmpty else {
            dismiss(animated: true)
            let message = "Enter Name!"
            showErrorAlert(with: message)
            return
        }
        
        save(name, room)
        
        if shouldShowPreview {
            preview(name: name, room: room)
        } else {
            join(name: name, room: room)
        }
    }
    
    private func join(name: String, room: String) {
        guard let viewController = UIStoryboard(name: Constants.meeting, bundle: nil)
            .instantiateInitialViewController() as? MeetingViewController
        else {
            return
        }
        
        viewController.interactor = HMSSDKInteractor(for: name, in: room)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func preview(name: String, room: String) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: Constants.previewControllerIdentifier) as? PreJoinPreviewViewController
        else {
            return
        }
        
        viewController.interactor = HMSSDKInteractor(for: name, in: room)
        
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
    
    // MARK: - Session Feedback
    
    /// Function to prompt the user to provide feedback on the session.
    private func collectFeedback() {
        
        // Create an alert controller to display feedback options.
        let alert = UIAlertController(title: SessionFeedback.feedbackTitle,
                                      message: SessionFeedback.feedbackSubTitle,
                                      preferredStyle: .actionSheet)
        
        // Add actions for various feedback options.
        alert.addAction(UIAlertAction(title: SessionFeedback.awful, style: .default, handler: { [weak self] action in
            self?.submitFeedback(.awful)
        }))
        alert.addAction(UIAlertAction(title: SessionFeedback.bad, style: .default, handler: { [weak self] action in
            self?.submitFeedback(.bad)
        }))
        alert.addAction(UIAlertAction(title: SessionFeedback.fair, style: .default, handler: { [weak self] action in
            self?.submitFeedback(.fair)
        }))
        alert.addAction(UIAlertAction(title: SessionFeedback.good, style: .default, handler: { [weak self] action in
            self?.submitFeedback(.good)
        }))
        alert.addAction(UIAlertAction(title: SessionFeedback.great, style: .default, handler: { [weak self] action in
            self?.submitFeedback(.great)
        }))
        
        // Add cancel action.
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Log the cancel action.
            print(#function, action.title as Any)
        }))
        
        // Present the alert controller to the user.
        self.present(alert, animated: true)
    }

    /// Function to submit feedback provided by the user.
    ///
    /// - Parameter rating: The rating provided by the user.
    private func submitFeedback(_ rating: HMSFeedbackRatingUI) {
        
        // Create an alert controller to gather additional comments from the user.
        let alert = UIAlertController(title: rating.toString(),
                                      message: rating.getQuestion(),
                                      preferredStyle: .alert)
        
        // Add text fields for reasons and additional comments.
        alert.addTextField { textField in
            textField.placeholder = "Reasons?" // Example: "Bad Audio"
        }
        alert.addTextField { textField in
            textField.placeholder = "Additional Comments?" // Example: "Could not hear others"
        }
        
        // Add submit action.
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { action in
            
            // Create a feedback object with the provided information.
            let feedback = HMSSessionFeedback(question: SessionFeedback.feedbackTitle,
                                              rating: rating.toInt(),
                                              minRating: 1,
                                              maxRating: 5,
                                              reasons: ["\(alert.textFields![0].text ?? "")"],
                                              comment: alert.textFields![1].text)
            
            // Submit the feedback to the SDK.
            HMSSDK.submitFeedback(feedback) { success, error in
                
                // Create an alert to inform the user about the submission status.
                let alert = UIAlertController(title: "Feedback Submitted",
                                              message: "\(success)",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                
                // Present the alert to the user.
                self.present(alert, animated: true)
            }
        }))
        
        // Present the alert controller to the user.
        self.present(alert, animated: true)
    }

}
