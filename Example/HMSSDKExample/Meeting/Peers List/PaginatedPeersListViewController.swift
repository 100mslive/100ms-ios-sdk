//
//  PeersListViewController.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 28/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK

final class PaginatedPeersListViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet private weak var participantsTitle: UIButton!

    @IBOutlet private  weak var table: UITableView!
    @IBOutlet private  weak var loadMoreButton: UIButton!
    @IBOutlet private  weak var searchBar: UISearchBar!

    internal var roomName: String!

    internal var meetingViewModel: MeetingViewModel?

    internal var speakers: [HMSViewModel]?

    typealias DataSource = UITableViewDiffableDataSource<PeersSection, HMSPeer>
    typealias Snapshot = NSDiffableDataSourceSnapshot<PeersSection, HMSPeer>

    private lazy var dataSource = makeDataSource()

    private var peers = [HMSPeer]()
    private var iterator: HMSPeerListIterator?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        observeParticipants()

        applySnapshot()
        
        searchBar.delegate = self

        iterator = meetingViewModel?.interactor?.hmsSDK?.getPeerListIterator(options: HMSPeerListIteratorOptions(limit: 10))
        loadPeers()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchPeers(searchText)
    }
    
    var currentQuery: String = ""
    
    func searchPeers(_ query: String) {
        self.loadMoreButton.isHidden = true
        
        currentQuery = query
        
        if query.isEmpty {
            self.peers = []
            self.applySnapshot()
            return
        }
        
        meetingViewModel?.interactor?.hmsSDK?.findPeersByName(query) { [weak self] foundPeers, error in
            guard let self = self, let foundPeers = foundPeers else { return }
            
            guard self.currentQuery == query else { return }
            
            self.peers = foundPeers
            self.applySnapshot()
        }
    }
    
    func loadPeers() {
        iterator?.next(completion: { [weak self] loadedPeers, error in
            guard let self = self else { return }
            if let loadedPeers = loadedPeers {
                self.peers.append(contentsOf: loadedPeers)
                self.applySnapshot()
                self.loadMoreButton.isHidden = !(iterator?.hasNext ?? false)
            }
        })
    }

    fileprivate func updatePeersCount() {
        let count = meetingViewModel?.interactor?.hmsSDK?.room?.peerCount ?? 0
        let title = "Peers " + (count > 0 ? "(\(count))" : "")
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
        if let role = peer.role?.name {
            cell.roleLabel.text = role.capitalized
        }
        cell.handRaiseButton.isHidden = !peer.isHandRaised

        if #available(iOS 14.0, *) {
            if let menu = meetingViewModel?.getMenu(for: peer) {
                cell.settingsButton.menu = menu
                cell.settingsButton.showsMenuAsPrimaryAction = true
                cell.settingsButton.isEnabled = true
            } else {
                cell.settingsButton.isEnabled = false
            }
        } else {
            // Fallback on earlier versions
        }

        updatePeersCount()

        updateSpeaker(cell, peer)
    }

    func updateSpeaker(_ cell: PeersListTableViewCell, _ peer: HMSPeer) {

        if speakers?.first(where: { $0.peer.peerID == peer.peerID }) != nil {
            let animatedImage = UIImage.animatedImage(with: animatedImages(), duration: 1)
            cell.speakingImageView.image = animatedImage
        } else {
            cell.speakingImageView.image = UIImage(systemName: "speaker.wave.2.fill")
        }
    }

    func applySnapshot(animatingDifferences: Bool = true) {

        guard let dataSource = dataSource else { return }

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
    
    @IBAction private func loadMoreTapped(_ sender: UIButton) {
        loadPeers()
    }
}

extension PaginatedPeersListViewController {

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
