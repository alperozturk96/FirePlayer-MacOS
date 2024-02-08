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
    func play(url: URL) {
        AppLogger.shared.info("SelectedTrack: \(url)")
        
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        resetDurations()
    }
    
    func seek(to seconds: Double) {
        let timeCM = CMTime(seconds: seconds, preferredTimescale: 100)
        player.seek(to: timeCM)
    }
    
    @MainActor
    private func resetDurations() {
        currentTime = 0
    }
    
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
    
    @objc
    private func triggerSelectNextTrackEvent() {
        publish(event: .next)
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
