//
//  MeetingViewModel.swift
//  HMSVideo_Example
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK

final class MeetingViewModel: NSObject,
                              UICollectionViewDelegate,
                              UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    private lazy var dataSource: HMSDataSource = {
        return HMSDataSource()
    }()

    internal var mode: ViewModes = .regular {
        didSet {
            switch mode {
            case .audioOnly, .speakers:
                dataSource.sortComparator = speakersSort(_:_:)
            case .videoOnly:
                dataSource.sortComparator = videoOnlySort(_:_:)
            case .regular, .pinned:
                dataSource.sortComparator = regularSort(_:_:)
            }
            dataSource.reload()
            collectionView?.reloadData()
            collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }

    private(set) var interactor: HMSSDKInteractor?

    private weak var collectionView: UICollectionView?

    private let sectionInsets = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)

    private var widthInsets: CGFloat {
        sectionInsets.left + sectionInsets.right
    }

    private var heightInsets: CGFloat {
        2*(sectionInsets.top + sectionInsets.bottom)
    }

    typealias DiffableDataSource = UICollectionViewDiffableDataSource<HMSSection, HMSViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<HMSSection, HMSViewModel>

    private lazy var diffableDataSource = makeDataSource()

    // MARK: Peers Data Source

    var shouldPlayAudio = true

    private var pinnedTiles = Set<String>()

    internal var speakers = [HMSViewModel]() {
        didSet {

            for speaker in oldValue where !speakers.contains(speaker) {
                clearSpeakerBorder(for: speaker)
            }

            for speaker in speakers where !oldValue.contains(speaker) {
                drawSpeakerBorder(for: speaker)
            }

            NotificationCenter.default.post(name: Constants.updatedSpeaker,
                                            object: nil,
                                            userInfo: ["speakers": speakers])

            if mode == .speakers || mode == .audioOnly {
                dataSource.reload()
            }
        }
    }

    // MARK: - Initializers

    init(_ user: String, _ room: String, _ flow: MeetingFlow, _ role: Int, _ collectionView: UICollectionView) {

        super.init()

        interactor = HMSSDKInteractor(for: user, in: room, flow, role) { [weak self] in
            self?.setupDataSource()
        }

        setup(collectionView)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setup(_ collectionView: UICollectionView) {
        collectionView.delegate = self
        self.collectionView = collectionView
    }

    private func setupDataSource() {
        dataSource.delegate = self
        interactor?.hms?.add(delegate: dataSource)
        dataSource.sortComparator = regularSort(_:_:)
    }

    private func regularSort(_ lhs: HMSViewModel, _ rhs: HMSViewModel) -> Bool {

        if let lhsTrackSource = lhs.videoTrack?.source.rawValue,
           let rhsTrackSource = rhs.videoTrack?.source.rawValue,
           lhsTrackSource != rhsTrackSource {
            return lhsTrackSource > rhsTrackSource
        } else if isPinned(lhs) != isPinned(rhs) {
            return isPinned(lhs) && !isPinned(rhs)
        } else if dataSource.allModels.count > 4 {
            return lhs.peer.name.lowercased() < rhs.peer.name.lowercased()
        } else {
            return !lhs.peer.isLocal && rhs.peer.isLocal
        }
    }

    private func videoOnlySort(_ lhs: HMSViewModel, _ rhs: HMSViewModel) -> Bool {
        if let lhsVideo = lhs.videoTrack, let rhsVideo = rhs.videoTrack {
            return !lhsVideo.isMute() && rhsVideo.isMute()
        } else {
            return lhs.videoTrack != nil
        }
    }

    private func speakersSort(_ lhs: HMSViewModel, _ rhs: HMSViewModel) -> Bool {

        if speakers.contains(lhs) {
            if let lhsIndex = diffableDataSource?.indexPath(for: lhs)?.item, lhsIndex < 4 {
                return false
            }
            return true
        }

        return false
    }

    // MARK: - View Modifiers

    private func makeDataSource() -> DiffableDataSource? {

        guard let collectionView = collectionView else { return nil }

        return DiffableDataSource(collectionView: collectionView) { (view, index, model) -> UICollectionViewCell? in

            guard let cell = view.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: index) as? VideoCollectionViewCell else {
                return nil
            }

            self.update(cell, for: model)

            return cell
        }
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        guard let diffableDataSource = diffableDataSource else { return }

        let sections = dataSource.sections

        var snapshot = Snapshot()

        snapshot.appendSections(sections)

        sections.forEach { section in
            snapshot.appendItems(section.models, toSection: section)
        }

        diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func update(_ cell: VideoCollectionViewCell, for viewModel: HMSViewModel) {

        cell.viewModel = viewModel

        cell.nameLabel.text = viewModel.peer.name

        cell.muteButton.isSelected = viewModel.peer.audioTrack?.isMute() ?? true

        cell.avatarLabel.text = Utilities.getAvatarName(from: viewModel.peer.name)

        //        cell.pinButton.isSelected = isPinned(viewModel)
        //        cell.onPinToggle = { [weak self] in
        //            self?.togglePinned(viewModel)
        //        }

        if speakers.contains(viewModel) {
            Utilities.applySpeakingBorder(on: cell)
        } else {
            Utilities.applyBorder(on: cell)
        }

        switch mode {
        case .audioOnly:
            cell.videoView.setVideoTrack(nil)
            cell.stopVideoButton.isSelected = true
            cell.avatarLabel.isHidden = false
        default:
            cell.videoView.setVideoTrack(viewModel.videoTrack)
            if let video = viewModel.videoTrack {
                cell.stopVideoButton.isSelected = video.isMute()
                cell.avatarLabel.isHidden = !video.isMute()
            } else {
                cell.stopVideoButton.isSelected = true
                cell.avatarLabel.isHidden = false
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.size.width - 2*widthInsets

        if let viewModel = diffableDataSource?.itemIdentifier(for: indexPath) {
            if isPinned(viewModel) ||
                viewModel.videoTrack?.source == .screen ||
                viewModel.videoTrack?.source == .plugin ||
                mode == .pinned {
                return .init(width: width,
                             height: collectionView.frame.size.height - heightInsets)
            }
        }

        if let count = diffableDataSource?.collectionView(collectionView, numberOfItemsInSection: indexPath.section) {

            switch count {
            case 0, 1:
                return .init(width: width,
                             height: collectionView.frame.size.height - heightInsets)
            case 2:
                return .init(width: width,
                             height: collectionView.frame.size.height/2 - heightInsets)
            case 3:
                return .init(width: width,
                             height: collectionView.frame.size.height/3 - heightInsets)
            default:
                if mode == .audioOnly && count > 5 {
                    return .init(width: width/2, height: collectionView.frame.size.height/3 - heightInsets)
                } else {
                    return .init(width: width/2,
                                 height: collectionView.frame.size.height/2.0 - heightInsets)
                }
            }
        }

        return .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        guard let videoCell = cell as? VideoCollectionViewCell,
              let model = diffableDataSource?.itemIdentifier(for: indexPath)
        else { return }

        if mode == .audioOnly {
            videoCell.videoView.setVideoTrack(nil)
        } else {
            videoCell.videoView.setVideoTrack(model.videoTrack)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        guard let videoCell = cell as? VideoCollectionViewCell else { return }

        videoCell.videoView.setVideoTrack(nil)
    }

    // MARK: - View Helpers

    private func cellFor(_ model: HMSViewModel) -> VideoCollectionViewCell? {
        guard  let collectionView = collectionView, let index = diffableDataSource?.indexPath(for: model) else { return nil }

        for cell in collectionView.visibleCells where collectionView.indexPath(for: cell) == index {
            if let videoCell = cell as? VideoCollectionViewCell {
                return videoCell
            }
        }
        return nil
    }

    private func drawSpeakerBorder(for model: HMSViewModel) {
        guard let cell = cellFor(model) else { return }

        Utilities.applySpeakingBorder(on: cell)
    }

    private func clearSpeakerBorder(for model: HMSViewModel) {
        guard let cell = cellFor(model) else { return }

        Utilities.applyBorder(on: cell)
    }

    // MARK: - Action Handlers

    func cleanup() {
        interactor?.hms?.leave()
        interactor?.hms = nil
        interactor = nil
    }

    private func togglePinned(_ model: HMSViewModel) {
        if !pinnedTiles.insert(model.identifier).inserted {
            pinnedTiles.remove(model.identifier)
        }
        dataSource.reload()
    }

    private func isPinned(_ model: HMSViewModel) -> Bool {
        pinnedTiles.contains(model.identifier)
    }

    func switchCamera() {
        if let track = interactor?.hms?.localPeer?.videoTrack as? HMSLocalVideoTrack {
            track.switchCamera()
        }
    }

    func switchAudio(isOn: Bool) {
        if let peer = interactor?.hms?.localPeer, let audioTrack = peer.audioTrack as? HMSLocalAudioTrack {
            audioTrack.setMute(!isOn)
            print(#function, isOn)
            NotificationCenter.default.post(name: Constants.peerAudioToggled, object: nil, userInfo: ["peer": peer])
        }
    }

    func switchVideo(isOn: Bool) {
        if let videoTrack = interactor?.hms?.localPeer?.videoTrack as? HMSLocalVideoTrack {
            videoTrack.setMute(!isOn)
            print(#function, isOn)
            NotificationCenter.default.post(name: Constants.peerVideoToggled,
                                            object: nil,
                                            userInfo: ["video": videoTrack])
        }
    }

    func muteRemoteStreams(_ isMuted: Bool) {

        setMuteStatus(isMuted, for: interactor?.hms?.room?.peers)

        shouldPlayAudio = isMuted

        NotificationCenter.default.post(name: Constants.muteALL, object: nil)
    }

    func setMuteStatus(_ isMuted: Bool, for peers: [HMSPeer]?) {
        if let peers = peers {
            for peer in peers {
                guard let remotePeer = peer as? HMSRemotePeer else { continue }
                remotePeer.remoteAudioTrack()?.setPlaybackAllowed(isMuted)
            }
        }
    }
}

extension MeetingViewModel: HMSDataSourceDelegate {

    func didUpdate(_ model: HMSViewModel?) {
        if let model = model, let cell = cellFor(model) {
            update(cell, for: model)
        }
        applySnapshot()
    }

    func didUpdate(_ speakers: [HMSViewModel]) {
        self.speakers = speakers
    }
}

enum ViewModes: String {
    case regular, audioOnly, videoOnly, speakers, pinned
}
