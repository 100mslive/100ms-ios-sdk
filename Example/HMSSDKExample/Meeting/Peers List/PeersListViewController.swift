//
//  PeersListViewController.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 28/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK

final class PeersListViewController: UIViewController {

    @IBOutlet private weak var participantsTitle: UIButton!

    @IBOutlet private  weak var table: UITableView!

    internal var interactor: HMSSDKInteractor?

    internal var speakers = [HMSViewModel]()

    typealias DataSource = UITableViewDiffableDataSource<PeersSection, HMSPeer>
    typealias Snapshot = NSDiffableDataSourceSnapshot<PeersSection, HMSPeer>

    private lazy var dataSource = makeDataSource()

    var peers: [HMSPeer]? {
        if let peers = interactor?.hms?.room?.peers {
            let sortedPeers = peers.sorted { (lhs, rhs) -> Bool in
                lhs.name.lowercased() < rhs.name.lowercased()
            }
            return sortedPeers
        }

        return nil
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        observeParticipants()

        applySnapshot()
    }

    fileprivate func updatePeersCount() {
        let count = interactor?.hms?.room?.peers.count ?? 0
        let title = "Participants " + (count > 0 ? "(\(count))" : "")
        participantsTitle.setTitle(title, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updatePeersCount()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - View Modifiers

    func makeDataSource() -> DataSource? {

        let dataSource = DataSource(tableView: table) { (table, indexPath, peer) -> UITableViewCell? in

            guard let cell = table.dequeueReusableCell(withIdentifier: "Cell",
                                                       for: indexPath) as? PeersListTableViewCell else {
                return nil
            }

            self.update(cell, for: peer)

            return cell
        }
        return dataSource
    }

    func update(_ cell: PeersListTableViewCell, for peer: HMSPeer) {
        cell.peer = peer
        cell.nameLabel.text = peer.name
        cell.roleLabel.text = peer.role.name

        updatePeersCount()

        updateSpeaker(cell, peer)
    }

    func updateSpeaker(_ cell: PeersListTableViewCell, _ peer: HMSPeer) {

        if speakers.first(where: { $0.peer.peerID == peer.peerID }) != nil {
            let animatedImage = UIImage.animatedImage(with: animatedImages(), duration: 1)
            cell.speakingImageView.image = animatedImage
        } else {
            cell.speakingImageView.image = UIImage(systemName: "speaker.wave.2.fill")
        }
    }

    func applySnapshot(animatingDifferences: Bool = true) {

        guard let peers = peers, let dataSource = dataSource else { return }

        var snapshot = Snapshot()

        snapshot.appendSections([.main])

        snapshot.appendItems(peers)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
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

        _ = NotificationCenter.default.addObserver(forName: Constants.updatedSpeaker,
                                                   object: nil,
                                                   queue: .main) { [weak self] notification in

            guard let userInfo = notification.userInfo,
                  let speakers = userInfo["speakers"] as? [HMSViewModel]
            else { return }

            self?.speakers = speakers

            for speaker in speakers {
                if let index = self?.dataSource?.indexPath(for: speaker.peer),
                   let cell = self?.table.cellForRow(at: index) as? PeersListTableViewCell {
                    self?.updateSpeaker(cell, speaker.peer)
                }
            }

            if speakers.count == 0 {
                self?.table.reloadData()
            }
        }
    }

    @objc private func updateList(with notification: Notification) {
        guard let userInfo = notification.userInfo,
              let peer = userInfo["peer"] as? HMSPeer,
              let dataSource = dataSource else { return }

        if let index = dataSource.indexPath(for: peer),
           let cell = table.cellForRow(at: index) as? PeersListTableViewCell {

            update(cell, for: peer)
        }

        applySnapshot()
    }

    @IBAction private func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension PeersListViewController {

    func animatedImages() -> [UIImage] {

        var images = [UIImage]()

        for counter in 1...3 {
            if let regular = UIImage(systemName: "speaker.wave.\(counter)")?.withTintColor(.link),
               let filled = UIImage(systemName: "speaker.wave.\(counter).fill")?.withTintColor(.link) {
                images.append(regular)
                images.append(filled)
            }
        }

        return images
    }
}

enum PeersSection {
    case main
}
