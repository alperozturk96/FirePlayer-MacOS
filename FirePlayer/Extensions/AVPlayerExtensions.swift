//
//  AudioPlayer.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 10.10.2023.
//

import Foundation
import AVFoundation

extension AVPlayer {
    func play(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        replaceCurrentItem(with: playerItem)
        play()
    }
    
    func toggle() {
        AudioPlayer.shared.isPlaying ? pause() : play()
    }
    
    var currrentDurationRepresentation: String? {
        if currentTime() < (currentItem?.duration ?? CMTime.zero) {
            return currentTime().positionalTime
        } else {
            return durationRepresentation
        }
    }
    
    var duration: Double? {
        guard let currentItemDuration = currentItem?.duration else { return nil }
        
        let durationInSeconds = CMTimeGetSeconds(currentItemDuration)
        
        return if durationInSeconds.isFinite {
            durationInSeconds
        } else {
            nil
        }
    }
    
    var durationRepresentation: String? {
        return currentItem?.duration.positionalTime
    }
}
