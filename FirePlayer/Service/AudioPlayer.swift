//
//  AudioPlayer.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 21.11.2023.
//

import AVFoundation
import Combine

final class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()
    
    private init() {
        observePlayerStatus()
    }
    
    @Published var player = AVPlayer()
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var totalTime: Double = 1
    private var cancellables: Set<AnyCancellable> = []
        
    // FIXME
    var isTrackFinished: Bool {
        return currentTime >= totalTime
    }
    
    @MainActor
    func play(url: URL) {
        AppLogger.shared.info("SelectedTrack: \(url)")
        
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.volume = 1
        player.play()
        
        updateDuration()
        updateCurrentTime()
    }
    
    func seek() {
        player.seek(to: CMTime(seconds: currentTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    @MainActor
    private func updateDuration() {
        Task {
            guard let duration = try? await player.currentItem?.asset.load(.duration) else { return }
            currentTime = 0
            totalTime = CMTimeGetSeconds(duration)
            AppLogger.shared.info("SelectedTrack TotalTime: " + totalTime.description)
        }
    }
    
    private func updateCurrentTime() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] elapsed in
            guard let self else { return }
            self.currentTime = CMTimeGetSeconds(self.player.currentTime())
        })
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

// MARK: - UI Helpers
extension AudioPlayer {
    var toggleText: String {
        isPlaying ? AppTexts.pause : AppTexts.play
    }
    
    var toggleIcon: String {
        isPlaying ? AppIcons.pause : AppIcons.play
    }
}
