//
//  AudioPlayer.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 21.11.2023.
//

import AVFoundation
import Combine

@MainActor
final class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()
    
    let userService = UserService()
    
    @Published var prevTrackIndexesStack: [Int] = []
    @Published var filteredTracks = [Track]()
    @Published var playMode: PlayMode = .shuffle
    @Published var selectedTrackIndex: Int = 0
    @Published var tracks = [Track]()
    
    private init() {
        observePlayerStatus()
        observeCurrentTime()
        addSelectNextTrackObserver()
    }
    
    @Published var player: AVPlayer = {
        let player = AVPlayer()
        player.volume = 1.0
        return player
    }()
    
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    private var cancellables: Set<AnyCancellable> = []
    
    @MainActor 
    func playSelectedTrack() {
        let track = filteredTracks[selectedTrackIndex]
        let savedTrackPosition = userService.readTrackPlaybackPosition(id: track.id)
        play(track: track, savedTrackPosition: savedTrackPosition)
        prevTrackIndexesStack.append(selectedTrackIndex)
    }
    
    @MainActor
    func play(track: Track, savedTrackPosition: Double?) {
        AppLogger.shared.info("SelectedTrack: \(track.path)")
        
        player.play(url: track.path)
        resetDurations()
        
        if let savedTrackPosition {
            seek(to: savedTrackPosition)
        }
    }
    
    func seek(to seconds: Double) {
        let timeCM = CMTime(seconds: seconds, preferredTimescale: 100)
        player.seek(to: timeCM)
    }
    
    @MainActor
    private func resetDurations() {
        currentTime = 0
    }
    
    @MainActor
    private func observeCurrentTime() {
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 100), queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
        }
    }
    
    private func addSelectNextTrackObserver() {
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(triggerSelectNextTrackEvent),
                         name: .AVPlayerItemDidPlayToEndTime,
                         object: player.currentItem)
    }
    
    @MainActor @objc
    private func triggerSelectNextTrackEvent() {
        selectNextTrack()
    }

    private func observePlayerStatus() {
        player.publisher(for: \.timeControlStatus)
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                switch status {
                case .playing:
                    self?.isPlaying = true
                case .paused, .waitingToPlayAtSpecifiedRate:
                    self?.isPlaying = false
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Public Functions
extension AudioPlayer {
    func addTracksFromGiven(folderURL: URL, onComplete: @escaping () -> ()) {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: []) else {
            return
        }
        
        Task(priority: .high) {
            let firstPageTrackCount = 30
            
            if urls.count >= firstPageTrackCount {
                await addTracks(Array(urls.prefix(firstPageTrackCount)))
                await addTracks(Array(urls.suffix(from: firstPageTrackCount)))
            } else {
                await addTracks(urls)
            }
            
            await MainActor.run {
                onComplete()
            }
            
            AppLogger.shared.info("Total Track Counts: \(filteredTracks.count)")
        }
    }
    
    func addTracks(_ urls: [URL]) async {
        for url in urls.supportedUrls {
            await tracks.append(url.toTrack())
        }
        
        await MainActor.run {
            tracks = tracks.sort(.aToZ)
            filteredTracks = tracks
        }
    }
    
    func search(_ filterOption: FilterOptions, searchText: String) {
        filteredTracks = if searchText.isEmpty {
            tracks
        } else {
            tracks.filter(filterOption, text: searchText).sort(.aToZ)
        }
    }
    
    func selectPreviousTrack() {
        guard prevTrackIndexesStack.count > 1 else { return }
        _ = prevTrackIndexesStack.popLast()
        
        if let prevIndex = prevTrackIndexesStack.last {
            selectedTrackIndex = prevIndex
        }
    }
    
    @MainActor
    func selectNextTrack() {
        if playMode == .loop {
            playSelectedTrack()
        } else {
            let nextIndex = (playMode == .shuffle) ? filteredTracks.randomIndex : (selectedTrackIndex < filteredTracks.count) ? selectedTrackIndex + 1 : 0
            selectedTrackIndex = nextIndex
        }
    }
}

// MARK: - UI Helpers
extension AudioPlayer {
    var toggleText: String {
        isPlaying ? AppTexts.pause : AppTexts.play
    }
    
    var toggleIcon: String {
        isPlaying ? AppIcons.pause : AppIcons.play
    }
}
