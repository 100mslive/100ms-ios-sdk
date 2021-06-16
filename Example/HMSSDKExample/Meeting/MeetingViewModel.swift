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

    internal var mode: ViewModes = .regular {
        didSet {
            switch mode {
            case .audioOnly:
                switchVideo(isOn: false)
                fallthrough
            case .speakers, .spotlight:
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

    private lazy var dataSource = {
        HMSDataSource()
    }()

    typealias DiffableDataSource = UICollectionViewDiffableDataSource<HMSSection, HMSViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<HMSSection, HMSViewModel>

    private lazy var diffableDataSource = makeDataSource()

    // MARK: Peers Data Source

    private var pinnedTiles = Set<String>()

    internal var speakers = [HMSViewModel]() {
        didSet {

            if mode == .speakers || mode == .audioOnly || mode == .spotlight {
                dataSource.reload()
            }
            
            if mode == .speakers {
                for speaker in oldValue where speaker != speakers.first {
                    animateSpeakerQuiet(speaker)
                }
                
                if let speaker = speakers.first {
                    animateSpeakerSpeaking(speaker)
                }
            }
            
            NotificationCenter.default.post(name: Constants.updatedSpeaker,
                                            object: nil,
                                            userInfo: ["speakers": speakers])
        }
    }
    
    private var shouldPlayAudio = true
    

    // MARK: - Initializers

    init(_ user: String, _ room: String, _ flow: MeetingFlow, _ role: Int, _ collectionView: UICollectionView) {

        super.init()

        interactor = HMSSDKInteractor(for: user, in: room, flow, role) { [weak self] in
            self?.setupDataSource()
        }

        setup(collectionView)
        
        addObservers()
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
        interactor?.hmsSDK?.add(delegate: dataSource)
        dataSource.sortComparator = regularSort(_:_:)
    }

    private func regularSort(_ lhs: HMSViewModel, _ rhs: HMSViewModel) -> Bool {

        let lhsTrackSource = lhs.videoTrack?.source.rawValue ?? 0
        let rhsTrackSource = rhs.videoTrack?.source.rawValue ?? 0
        
        let lhsAuxTracks = lhs.peer.auxiliaryTracks?.count ?? 0
        let rhsAuxTracks = rhs.peer.auxiliaryTracks?.count ?? 0
        
        if lhsTrackSource != rhsTrackSource {
            return lhsTrackSource > rhsTrackSource
        } else if isPinned(lhs) != isPinned(rhs) {
            return isPinned(lhs) && !isPinned(rhs)
        } else if lhsAuxTracks != rhsAuxTracks {
            return lhsAuxTracks > rhsAuxTracks
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
            var count = 4
            if mode == .audioOnly {
                count = 6
            } else if mode == .spotlight {
                count = 1
            }
            
            if let lhsIndex = diffableDataSource?.indexPath(for: lhs)?.item, lhsIndex < count {
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

        if mode == .spotlight {
            return .init(width: collectionView.frame.size.width,
                         height: collectionView.frame.size.height)
        }
        
        if let size = sizeFor(indexPath: indexPath, collectionView) {
            return size
        }

        if let count = diffableDataSource?.collectionView(collectionView, numberOfItemsInSection: indexPath.section) {

            switch count {
            case 0, 1:
                return .init(width: collectionView.frame.size.width,
                             height: collectionView.frame.size.height)
            case 2:
                return .init(width: collectionView.frame.size.width,
                             height: collectionView.frame.size.height/2)
            case 3:
                return .init(width: collectionView.frame.size.width,
                             height: collectionView.frame.size.height/3)
            default:
                if mode == .audioOnly && count > 5 {
                    return .init(width: collectionView.frame.size.width/2,
                                 height: collectionView.frame.size.height/3)
                } else {
                    return .init(width: collectionView.frame.size.width/2,
                                 height: collectionView.frame.size.height/2.0)
                }
            }
        }

        return .zero
    }
    
    private func sizeFor(indexPath: IndexPath, _ collectionView: UICollectionView) -> CGSize? {
        let isLandscape = UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft
        
        if mode == .pinned || mode == .regular || mode == .videoOnly || isLandscape,
           let viewModel = diffableDataSource?.itemIdentifier(for: indexPath) {
            if isPinned(viewModel) ||
                viewModel.videoTrack?.source == .screen ||
                viewModel.videoTrack?.source == .plugin ||
                mode == .pinned ||
                isLandscape {
                return .init(width: collectionView.frame.size.width,
                             height: collectionView.frame.size.height)
            }
        }
        return nil
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
    
    private func animateSpeakerSpeaking(_ model: HMSViewModel) {
        
        let count = mode == .audioOnly ? 6 : 4
        
        guard let cell = cellFor(model),
              let collectionView = collectionView,
              let total = self.diffableDataSource?.collectionView(collectionView, numberOfItemsInSection: 0), total > 4,
              let index = diffableDataSource?.indexPath(for: model),
              index.item < count || index.item == 0 else { return }
        
        UIView.animate(withDuration: 0.5) {
            
            cell.layer.zPosition = 1000.0
            
            var x = 0.5, y = 0.5

            if cell.center.x < collectionView.center.x {
                x = 0.43
            } else {
                x = 0.57
            }
            
            if cell.center.y < collectionView.center.y {
                y = 0.43
            } else {
                y = 0.57
            }
            
            cell.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            cell.layer.anchorPoint = .init(x: x, y: y)
        }
    }
    
    private func animateSpeakerQuiet(_ model: HMSViewModel) {
        guard let cell = cellFor(model) else { return }
        UIView.animate(withDuration: 0.1) {
            cell.transform = .identity
            cell.layer.zPosition = 0
            cell.layer.anchorPoint = .init(x: 0.5, y: 0.5)
        }
    }
    
    private func addObservers() {
     
        _ = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.collectionView?.reloadData()
            }
        }
        _ = NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            self?.cleanup()
        }
    }

    // MARK: - Action Handlers

    func cleanup() {
        interactor?.hmsSDK?.leave()
        interactor?.hmsSDK = nil
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
        if let track = interactor?.hmsSDK?.localPeer?.videoTrack as? HMSLocalVideoTrack {
            track.switchCamera()
        }
    }

    func switchAudio(isOn: Bool) {
        if let peer = interactor?.hmsSDK?.localPeer, let audioTrack = peer.audioTrack as? HMSLocalAudioTrack {
            audioTrack.setMute(!isOn)
            NotificationCenter.default.post(name: Constants.toggleAudioTapped, object: nil, userInfo: ["peer": peer])
        }
    }

    func switchVideo(isOn: Bool) {
        guard let videoTrack = interactor?.hmsSDK?.localPeer?.videoTrack as? HMSLocalVideoTrack else {
            return
        }
        videoTrack.setMute(!isOn)
        NotificationCenter.default.post(name: Constants.toggleVideoTapped,
                                        object: nil,
                                        userInfo: ["video": videoTrack])
    }

    func muteRemoteStreams(_ isMuted: Bool) {

        shouldPlayAudio = isMuted
        
        setMuteStatus()

        NotificationCenter.default.post(name: Constants.muteALL, object: nil)
    }

    func setMuteStatus() {
        for model in dataSource.allModels {
            if let peer = model.peer as? HMSRemotePeer,
               let audio = peer.remoteAudioTrack(),
               audio.isPlaybackAllowed() != shouldPlayAudio {
                audio.setPlaybackAllowed(shouldPlayAudio)
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
        
        setMuteStatus()
    }

    func didUpdate(_ speakers: [HMSViewModel]) {
        self.speakers = speakers
    }
}

enum ViewModes: String {
    case regular, audioOnly, videoOnly, speakers, pinned, spotlight
}
