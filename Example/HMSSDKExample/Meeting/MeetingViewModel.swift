//
//  MeetingViewModel.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 26/02/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK

final class MeetingViewModel: NSObject,
                              UICollectionViewDelegate,
                              UICollectionViewDelegateFlowLayout {
    
    weak var delegate: MeetingViewController?

    // MARK: - Properties

    var mode: ViewModes = .regular {
        didSet {
            switch mode {
            case .audioOnly:
                switchVideo(isOn: false)
                fallthrough
            case .speakers, .spotlight, .hero:
                dataSource.sortComparator = speakersSort(_:_:)
            case .videoOnly:
                dataSource.sortComparator = videoOnlySort(_:_:)
            case .regular, .pinned:
                dataSource.sortComparator = regularSort(_:_:)
            }
            if oldValue == .speakers {
                dataSource.allModels.forEach { model in
                    applyQuietBorder(model)
                }
            }
            if mode == .hero {
                if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .vertical
                }
            } else if oldValue == .hero {
                if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .horizontal
                }
            }
            dataSource.reload()
            collectionView?.reloadData()
            collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }

    internal var showRoleChangePrompt: ((HMSPeer, Bool) -> Void)?

    internal var updateLocalPeerTracks: (() -> Void)?

    private(set) var interactor: HMSSDKInteractor?

    private weak var collectionView: UICollectionView?

    private lazy var dataSource = {
        HMSDataSource()
    }()

    private typealias DiffableDataSource = UICollectionViewDiffableDataSource<HMSSection, HMSViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<HMSSection, HMSViewModel>

    private lazy var diffableDataSource = makeDataSource()

    private var pinnedTiles = Set<String>()

    internal var speakers = [HMSViewModel]() {
        didSet {

            if mode == .speakers || mode == .audioOnly || mode == .spotlight || mode == .hero {
                dataSource.reload()
            }

            for speaker in oldValue {
                applyQuietBorder(speaker)
            }

            for speaker in speakers {
                applySpeakingBorder(speaker)
            }

            NotificationCenter.default.post(name: Constants.updatedSpeaker,
                                            object: nil,
                                            userInfo: ["speakers": speakers])
        }
    }

    private var shouldPlayAudio = true

    // MARK: - Initializers

    init(_ user: String, _ room: String, _ collectionView: UICollectionView, interactor: HMSSDKInteractor) {

        super.init()

        self.interactor = interactor
        setupDataSource()

        setup(collectionView)

        addObservers()

        self.interactor?.updatedMuteStatus = { [weak self] audio in
            self?.setMuteStatus(audio)
        }
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

    private func order(for trackSource: String?) -> Int {
        guard let trackSource = trackSource else {
            return 0
        }

        switch trackSource {
        case HMSCommonTrackSource.regular:
            return 1
        case HMSCommonTrackSource.screen:
            return 2
        case HMSCommonTrackSource.plugin:
            return 3
        default:
            break
        }

        return 0
    }

    private func regularSort(_ lhs: HMSViewModel, _ rhs: HMSViewModel) -> Bool {

        let lhsTrackSource = order(for: lhs.videoTrack?.source)
        let rhsTrackSource = order(for: rhs.videoTrack?.source)

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

        let lhsTrackSource = order(for: lhs.videoTrack?.source)
        let rhsTrackSource = order(for: rhs.videoTrack?.source)

        let lhsAuxTracks = lhs.peer.auxiliaryTracks?.count ?? 0
        let rhsAuxTracks = rhs.peer.auxiliaryTracks?.count ?? 0

        if lhsTrackSource != rhsTrackSource {
            return lhsTrackSource > rhsTrackSource
        } else if lhsAuxTracks != rhsAuxTracks {
            return lhsAuxTracks > rhsAuxTracks
        }

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

    // MARK: - Collection View Helpers

    private func makeDataSource() -> DiffableDataSource? {

        guard let collectionView = collectionView else { return nil }

        return DiffableDataSource(collectionView: collectionView) { [weak self] (view, index, model) -> UICollectionViewCell? in

            guard let cell = view.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: index) as? VideoCollectionViewCell else {
                return nil
            }

            self?.update(cell, for: model)

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

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let viewModel = diffableDataSource?.itemIdentifier(for: indexPath) else { return .zero }

        if mode == .spotlight {
            return .init(width: collectionView.frame.size.width,
                         height: collectionView.frame.size.height)
        } else if mode == .hero {
            if indexPath.item == 0 {
                return .init(width: collectionView.frame.size.width,
                             height: collectionView.frame.size.height * 0.75)
            } else {
                return .init(width: collectionView.frame.size.width * 0.33,
                             height: collectionView.frame.size.height * 0.25)
            }
        }

        if shouldBeFullScreen(indexPath, collectionView, viewModel) {
            return .init(width: collectionView.frame.size.width,
                         height: collectionView.frame.size.height)
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
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return .init(width: collectionView.frame.size.width,
                                 height: collectionView.frame.size.height/2.0)
                } else {
                    return .init(width: collectionView.frame.size.width,
                                 height: collectionView.frame.size.height/3)
                }
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

    private func shouldBeFullScreen(_ indexPath: IndexPath, _ collectionView: UICollectionView, _ viewModel: HMSViewModel) -> Bool {

        if UIDevice.current.userInterfaceIdiom == .pad {
            if viewModel.videoTrack?.source == HMSCommonTrackSource.screen ||
                viewModel.videoTrack?.source == HMSCommonTrackSource.plugin {
                return true
            }
            return false
        }

        let isLandscape = UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft

        if viewModel.videoTrack?.source == HMSCommonTrackSource.screen ||
            viewModel.videoTrack?.source == HMSCommonTrackSource.plugin ||
            mode == .pinned ||
            isLandscape {
            return true
        }

        return false
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        guard let videoCell = cell as? VideoCollectionViewCell else { return }

        videoCell.videoView.setVideoTrack(nil)

        Utilities.applyBorder(on: cell)
    }

    // MARK: - Video View Helpers

    private func update(_ cell: VideoCollectionViewCell, for viewModel: HMSViewModel) {

        cell.viewModel = viewModel

        cell.nameLabel.text = viewModel.peer.name

        cell.muteButton.isSelected = getMuteButtonStatus(for: viewModel)

        cell.avatarLabel.text = Utilities.getAvatarName(from: viewModel.peer.name)

        cell.handIcon.isHidden = !(viewModel.peer.peerMetadataObject?.isHandRaised ?? false)
        
        cell.networkQualityView.quality = viewModel.peer.networkQuality?.downlinkQuality ?? -1

        setViewOptions(for: cell, using: viewModel)

        removeHighlightOnMute(viewModel)

        setMoreButton(for: cell, using: viewModel)

        setVideoTrack(for: cell, using: viewModel)
    }

    private func getMuteButtonStatus(for viewModel: HMSViewModel) -> Bool {

        if let video = viewModel.videoTrack {
            if video.source == HMSCommonTrackSource.screen || video.source == HMSCommonTrackSource.plugin {
                if let auxTracks = viewModel.peer.auxiliaryTracks {
                    for track in auxTracks where track.kind == .audio {
                        return track.isMute()
                    }
                }
            }
        }

        guard let audio = viewModel.peer.audioTrack else { return true }

        if let localAudio = audio as? HMSLocalAudioTrack {
            return localAudio.isMute()
        } else if let remoteAudio = audio as? HMSRemoteAudioTrack {
            if remoteAudio.isPlaybackAllowed() {
                return remoteAudio.isMute()
            }
        }

        return true
    }

    private func setViewOptions(for cell: VideoCollectionViewCell, using viewModel: HMSViewModel) {
        
        if let localVideoTrack = cell.viewModel?.videoTrack as? HMSLocalVideoTrack {
            let mirrorEnabled = UserDefaults.standard.object(forKey: Constants.mirrorMyVideo) as? Bool ?? true
            cell.videoView.mirror = localVideoTrack.settings.cameraFacing == .front && mirrorEnabled
        }
        else {
            cell.videoView.mirror = false
        }
        
        cell.videoView.videoContentMode = .scaleAspectFill

        if viewModel.peer is HMSRemotePeer {

            if viewModel.videoTrack?.source == HMSCommonTrackSource.screen || viewModel.videoTrack?.source == HMSCommonTrackSource.plugin {
                cell.videoView.videoContentMode = .scaleAspectFit
                cell.moreButton.isHidden = true
            } else {
                cell.moreButton.isHidden = false
            }
            
            // Let's enable panning and zooming in screen share view
            if viewModel.videoTrack?.source == HMSCommonTrackSource.screen {
                cell.videoView.isZoomAndPanEnabled = true
            }
            else {
                cell.videoView.isZoomAndPanEnabled = false
            }
        }
        else {
            cell.videoView.isZoomAndPanEnabled = false
        }
    }

    private func removeHighlightOnMute(_ viewModel: HMSViewModel) {
        if let audio = viewModel.peer.audioTrack {
            if audio.isMute() {
                applyQuietBorder(viewModel)
            }
        }
    }

    private func setMoreButton(for cell: VideoCollectionViewCell, using viewModel: HMSViewModel) {
        if #available(iOS 14.0, *) {
            if let menu = getMenu(for: nil, model: viewModel) {
                cell.moreButton.menu = menu
                cell.moreButton.showsMenuAsPrimaryAction = true
                cell.moreButton.isEnabled = true
            } else {
                cell.moreButton.isEnabled = false
            }
        } else {
            // Fallback on earlier versions
        }
    }

    private func setVideoTrack(for cell: VideoCollectionViewCell, using viewModel: HMSViewModel) {
        switch mode {

        case .audioOnly:
            cell.videoView.setVideoTrack(nil)
            cell.stopVideoButton.isSelected = true
            cell.avatarLabel.isHidden = false

        default:
            cell.videoView.setVideoTrack(viewModel.videoTrack)

            cell.videoView.isHidden = !viewModel.isVideoOn
            cell.avatarLabel.isHidden = viewModel.isVideoOn
            cell.isDegradedIcon.isHidden = !viewModel.isDegraded

            cell.stopVideoButton.isSelected = !viewModel.isVideoOn
        }
    }

    // MARK: - View Modifiers

    private func cellFor(_ model: HMSViewModel) -> VideoCollectionViewCell? {
        guard  let collectionView = collectionView, let index = diffableDataSource?.indexPath(for: model) else { return nil }

        for cell in collectionView.visibleCells where collectionView.indexPath(for: cell) == index {
            if let videoCell = cell as? VideoCollectionViewCell {
                return videoCell
            }
        }
        return nil
    }

    private func applySpeakingBorder(_ model: HMSViewModel) {
        guard let cell = cellFor(model) else { return }
        Utilities.applySpeakingBorder(on: cell)
    }

    private func applyQuietBorder(_ model: HMSViewModel?) {
        guard let model = model, let cell = cellFor(model) else { return }
        Utilities.applyBorder(on: cell)
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

    // MARK: - Role based Actions

    internal func getMenu(for peer: HMSPeer? = nil, model: HMSViewModel? = nil) -> UIMenu? {

        guard let peer = peer ?? model?.peer else { return nil }
        
        var actions: [UIAction]?

        if let peer = peer as? HMSLocalPeer {
            actions = getLocalPeerActions(peer)
            
            if let localVideoTrack = peer.localVideoTrack() {
                
                if !localVideoTrack.isMute() {
                    
                    actions?.append(UIAction(title: "Toggle Torch", image: UIImage(systemName: "flashlight.on.fill")) { _ in
                        
                        localVideoTrack.modifyCaptureDevice({ device in
                            guard let device = device else { return }
                            guard device.isTorchModeSupported(.on) else {
                                self.delegate?.presentAlert(with: "Not supported", message: "Torch is not supported on this camera")
                                return
                            }
                            device.torchMode = device.torchMode == .off ? .on : .off
                        })
                    })
                    
                    actions?.append(UIAction(title: "Zoom camera in/out", image: UIImage(systemName: "plus.magnifyingglass")) { _ in
                        
                        localVideoTrack.modifyCaptureDevice({ device in
                            guard let device = device else { return }
                            device.videoZoomFactor = device.videoZoomFactor == 1.0 ? 2.0 : 1.0
                        })
                    })
                    
                    actions?.append(UIAction(title: "Take photo", image: UIImage(systemName: "camera.fill")) { _ in
                        
                        localVideoTrack.captureImageAtMaxSupportedResolution(withFlash: false, completion: { image in
                            if let image = image {
                                self.delegate?.presentSheet(with: image)
                            }
                        })
                    })
                }
            }
            
        } else if let peer = peer as? HMSRemotePeer {
            actions = getRemotePeerActions(peer)
        }

        if let videoTrack = peer.videoTrack {
            
            if !videoTrack.isMute() {
                
                if let model = model {
                    
                    actions?.append(UIAction(title: "Capture Snapshot", image: UIImage(systemName: "photo.circle")) { [weak self] _ in
                        
                        if let image = self?.cellFor(model)?.videoView.captureSnapshot() {
                            self?.delegate?.presentSheet(with: image)
                        }
                    })
                }
            }
        }
        
        guard let actions = actions else { return nil }

        return UIMenu(title: "Select action for \(peer.name)",
                      children: actions)
    }

    private func getLocalPeerActions(_ peer: HMSLocalPeer) -> [UIAction]? {

        guard let interactor = interactor else { return nil }

        if interactor.canChangeRole {
            return [UIAction(title: "Change Self Role", image: UIImage(systemName: "arrow.up.and.person.rectangle.portrait")) { [weak self] _ in
                self?.showRoleChangePrompt?(peer, true)
            }]
        }
        return nil
    }

    private func getRemotePeerActions(_ peer: HMSRemotePeer) -> [UIAction]? {

        guard let interactor = interactor else { return nil }

        var actions = [UIAction]()

        if interactor.canChangeRole {

            actions.append(UIAction(title: "Request to Change Role", image: UIImage(systemName: "person.crop.rectangle")) { [weak self] _ in
                self?.showRoleChangePrompt?(peer, false)
            })

            actions.append(UIAction(title: "Force Change Role", image: UIImage(systemName: "arrow.up.and.person.rectangle.portrait")) { [weak self] _ in
                self?.showRoleChangePrompt?(peer, true)
            })
        }

        if interactor.canRemoteMute {

            if let audioTrack = peer.remoteAudioTrack() {

                let shouldMute = !audioTrack.isMute()
                let actionName = shouldMute ? "Mute Audio" : "Ask To Unmute Audio"
                let image = shouldMute ? UIImage(systemName: "speaker.slash.fill") : UIImage(systemName: "speaker.wave.3.fill")

                actions.append(UIAction(title: actionName, image: image) { [weak self] _ in
                    self?.interactor?.hmsSDK?.changeTrackState(for: audioTrack, mute: shouldMute)
                })
            }

            if let videoTrack = peer.remoteVideoTrack() {

                let shouldMute = !videoTrack.isMute()
                let actionName = shouldMute ? "Mute Video" : "Ask To Unmute Video"
                let image = shouldMute ? UIImage(systemName: "video.slash.fill") : UIImage(systemName: "video.fill")

                actions.append(UIAction(title: actionName, image: image) { [weak self] _ in
                    self?.interactor?.hmsSDK?.changeTrackState(for: videoTrack, mute: shouldMute)
                })
            }
        }

        if interactor.canRemovePeer {
            actions.append(UIAction(title: "Remove Peer", image: UIImage(systemName: "person.fill.badge.minus")) { [weak self] _ in
                self?.interactor?.hmsSDK?.removePeer(peer, reason: "You are being removed from the room.")
            })
        }

        if mode != .audioOnly, let layerDefinitions = peer.remoteVideoTrack()?.layerDefinitions {

            let layerNameMap: [HMSSimulcastLayer: String] = [ .high: "high", .mid: "mid", .low: "low" ]
            let imageMap: [HMSSimulcastLayer: String] = [ .high: "wifi", .mid: "antenna.radiowaves.left.and.right", .low: "personalhotspot"]

            layerDefinitions.forEach {

                let layer = $0.layer
                guard let layerName = layerNameMap[layer],
                      let imageName = imageMap[layer]
                else { return }

                actions.append(UIAction(title: "Select \(layerName) layer", image: UIImage(systemName: imageName)) { _ in
                    peer.remoteVideoTrack()?.layer = layer
                })
            }
        }

        return actions
    }

    // MARK: - Action Handlers

    internal func cleanup() {
        dataSource.delegate = nil
        dataSource.sortComparator = nil
        interactor?.hmsSDK?.leave()
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

    internal func switchCamera() {
        if let track = interactor?.hmsSDK?.localPeer?.videoTrack as? HMSLocalVideoTrack {
            track.switchCamera()
            NotificationCenter.default.post(name: Constants.switchCameraTapped,
                                            object: nil,
                                            userInfo: ["cameraFacing": track.settings.cameraFacing])
        }
    }

    internal func switchAudio(isOn: Bool) {
        if let peer = interactor?.hmsSDK?.localPeer, let audioTrack = peer.audioTrack as? HMSLocalAudioTrack {
            audioTrack.setMute(!isOn)
            NotificationCenter.default.post(name: Constants.toggleAudioTapped, object: nil, userInfo: ["peer": peer])
        }
    }

    internal func switchVideo(isOn: Bool) {
        guard let videoTrack = interactor?.hmsSDK?.localPeer?.videoTrack as? HMSLocalVideoTrack else {
            return
        }
        videoTrack.setMute(!isOn)
        NotificationCenter.default.post(name: Constants.toggleVideoTapped,
                                        object: nil,
                                        userInfo: ["video": videoTrack])
    }

    internal func muteRemoteStreams(_ isMuted: Bool) {

        shouldPlayAudio = isMuted

        setMuteStatus()

        NotificationCenter.default.post(name: Constants.muteALL, object: nil)
    }

    private func setMuteStatus(_ audio: HMSAudioTrack? = nil) {
        let volume = shouldPlayAudio ? 1.0 : 0.0

        for model in dataSource.allModels {
            if let peer = model.peer as? HMSRemotePeer {
                if let audio = peer.remoteAudioTrack() {
                    audio.setVolume(volume)
                }
                if let auxTracks = model.peer.auxiliaryTracks {
                    for track in auxTracks {
                        if let audio = track as? HMSRemoteAudioTrack {
                            audio.setVolume(volume)
                        }
                    }
                }
            }
        }
        if let remoteAudio = audio as? HMSRemoteAudioTrack {
            remoteAudio.setVolume(volume)
        }
    }
}

// MARK: - Data Source Delegate

extension MeetingViewModel: HMSDataSourceDelegate {

    func didUpdate(_ model: HMSViewModel?) {
        if let model = model, let cell = cellFor(model) {
            update(cell, for: model)
        }

        if model?.peer.isLocal == true || model == nil {
            updateLocalPeerTracks?()
        }

        setMuteStatus()
        applySnapshot()
    }

    func didUpdate(_ speakers: [HMSViewModel]) {
        self.speakers = speakers
    }
}

extension HMSViewModel {
    var isDegraded: Bool {
        videoTrack?.isDegraded() ?? false
    }
    
    var isVideoOn: Bool {
        guard let videoTrack = videoTrack, !videoTrack.isMute(), !isDegraded  else {
            return false
        }
        
        if let remoteVideo = videoTrack as? HMSRemoteVideoTrack {
            return remoteVideo.isPlaybackAllowed()
        }
        
        return true
    }
}
