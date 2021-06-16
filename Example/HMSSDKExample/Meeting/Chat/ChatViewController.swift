//
//  ChatViewController.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 28/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK

final class ChatViewController: UIViewController {

    internal var interactor: HMSSDKInteractor?

    @IBOutlet private weak var table: UITableView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!

    typealias DataSource = UITableViewDiffableDataSource<ChatSection, HMSMessage>
    typealias Snapshot = NSDiffableDataSourceSnapshot<ChatSection, HMSMessage>

    private lazy var dataSource = makeDataSource()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        table.tableFooterView = UIView()
        table.estimatedRowHeight = 64
        table.rowHeight = UITableView.automaticDimension
        table.tableFooterView = stackView

        observeBroadcast()
        handleKeyboard()
        applySnapshot()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - View Modifiers

    private func handleKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo,
              var keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        else { return }

        keyboardFrame = view.convert(keyboardFrame, from: nil)

        var contentInset = table.contentInset
        contentInset.bottom = keyboardFrame.size.height + 30
        table.contentInset = contentInset
    }

    @objc private func keyboardWillHide(notification: NSNotification) {

        let contentInset = UIEdgeInsets.zero
        table.contentInset = contentInset
    }

    // MARK: - Action Handlers

    private func observeBroadcast() {
        _ = NotificationCenter.default.addObserver(forName: Constants.messageReceived,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            self?.applySnapshot()
            self?.table.scrollToBottom()
        }
    }

    @IBAction private func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction private func sendTapped(_ sender: UIButton) {

        guard let message = textField.text,
              !message.isEmpty,
              let interactor = interactor,
              let peerID = interactor.hmsSDK?.localPeer?.peerID else { return }

        sender.isEnabled = false

        let broadcast = HMSMessage(sender: peerID,
                                   receiver: "",
                                   time: "\(Date())",
                                   type: "chat",
                                   message: message)

        interactor.hmsSDK?.send(message: broadcast)

        interactor.messages.append(broadcast)

        applySnapshot()

        if let index = dataSource?.indexPath(for: broadcast) {
            table.scrollToRow(at: index, at: .top, animated: true)
        }

        sender.isEnabled = true

        textField.text = ""
    }
}

extension ChatViewController {

    func makeDataSource() -> DataSource? {

        let dataSource = DataSource(tableView: table) { (table, indexPath, message) -> UITableViewCell? in

            guard let cell = table.dequeueReusableCell(withIdentifier: "Cell",
                                                       for: indexPath) as? ChatTableViewCell else {
                return nil
            }

            self.update(cell, for: message)

            return cell
        }
        return dataSource
    }

    func update(_ cell: ChatTableViewCell, for message: HMSMessage) {

        var name = message.sender
        var isLocal = false

        if let room = interactor?.hmsSDK?.room, let peer = HMSUtilities.getPeer(for: message.sender, in: room) {
            name = peer.name
            isLocal = (peer.peerID == interactor?.hmsSDK?.localPeer?.peerID)
        }

        if isLocal {
            cell.nameLabel.textAlignment = .right
            cell.messageLabel.textAlignment = .right
        } else {
            cell.nameLabel.textAlignment = .left
            cell.messageLabel.textAlignment = .left
        }

        cell.nameLabel.text = name
        cell.messageLabel.text = message.message
    }

    func applySnapshot(animatingDifferences: Bool = true) {

        guard let messages = interactor?.messages, let dataSource = dataSource else { return }

        var snapshot = Snapshot()

        snapshot.appendSections([.main])

        snapshot.appendItems(messages)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension ChatViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped(sendButton)
        return true
    }
}

enum ChatSection {
    case main
}

extension UITableView {

    func scrollToBottom() {

        DispatchQueue.main.async {
            let point = CGPoint(x: 0, y: self.contentSize.height + self.contentInset.bottom - self.frame.height)
            if point.y >= 0 {
                self.setContentOffset(point, animated: true)
            }
        }
    }
}
