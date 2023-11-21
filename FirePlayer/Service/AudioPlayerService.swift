//
//  AudioPlayerService.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 21.11.2023.
//

import Foundation
import AVFoundation

final class AudioPlayerService: ObservableObject {
    @Published var player = AVPlayer()
    @Published var currentTime: Double = 0
    @Published var totalTime: Double = 0
    
    @MainActor 
    func play(url: URL) {
        print("Path: ", url)
        
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.volume = 1
        player.play()
        
        updateDuration()
        updateCurrentTime()
    }
    
    func seek(to time: Double) {
        let timeCM = CMTime(seconds: time, preferredTimescale: 1)
        player.seek(to: timeCM)
    }
    
    @MainActor
    private func updateDuration() {
        Task {
            guard let duration = try? await player.currentItem?.asset.load(.duration) else { return }
            currentTime = 0
            totalTime = CMTimeGetSeconds(duration)
        }
    }
    
    private func updateCurrentTime() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] elapsed in
            guard let self else { return }
            self.currentTime = CMTimeGetSeconds(self.player.currentTime())
        })
    }
}
