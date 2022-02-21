//
//  PeersListViewController.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 28/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK

final class PreviewPeersListViewController: UIViewController {

    @IBOutlet private weak var participantsTitle: UIButton!

    @IBOutlet private  weak var table: UITableView!

    internal var roomName: String!

    @IBOutlet weak var roomNameButton: UIButton! {
        didSet {
            roomNameButton.setTitle(roomName, for: .normal)
        }
    }
    
    var interactor: HMSSDKInteractor!

    internal var peers: [HMSPeer] = [] {
        didSet {
            table.reloadData()
            updatePeersCount()
        }
    }
    
    func sortedPeers() -> [HMSPeer] {
        guard let room = interactor.hmsSDK?.room else { return [] }
        return room.peers.filter { !$0.isLocal }
                         .sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        peers = sortedPeers()
        observeParticipants()
    }

    fileprivate func updatePeersCount() {
        let count = peers.count
        let title = "Peers " + (count > 0 ? "(\(count))" : "")
        participantsTitle.setTitle(title, for: .normal)
    }

    // MARK: - View Modifiers

    func update(_ cell: PeersListTableViewCell, for peer: HMSPeer) {
        cell.peer = peer
        cell.nameLabel.text = peer.name
        if let role = peer.role?.name {
            cell.roleLabel.text = role.capitalized
        }

        updatePeersCount()
    }

    // MARK: - Action Handlers

    private func observeParticipants() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateList(with:)),
                                               name: Constants.joinedRoom,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateList(with:)),
                                               name: Constants.peersUpdated,
                                               object: nil)
    }

    @objc private func updateList(with notification: Notification) {
        peers = sortedPeers()
    }

    @IBAction private func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
 
extension PreviewPeersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: "Cell",
                                                   for: indexPath) as? PeersListTableViewCell else {
            return UITableViewCell()
        }
        
        

        self.update(cell, for: peers[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peers.count
    }
}
