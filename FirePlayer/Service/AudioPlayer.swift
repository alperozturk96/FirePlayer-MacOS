//
//  AudioPlayer.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 10.10.2023.
//

import Foundation
import AVFoundation

final class AudioPlayer: ObservableObject {
    @Published var player: AVPlayer = AVPlayer()
    
    func play(url: URL) {
        print("Path: ", url)
        
        player = AVPlayer(url: url)
        player.volume = 1
        player.play()
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        rate != 0 && error == nil
    }
    
    var duration: Double? {
        if let currentItem = currentItem {
            return CMTimeGetSeconds(currentItem.duration)
        }
        
        return nil
    }
    
    var currentDuration: Double? {
        if let currentItem = currentItem {
            return CMTimeGetSeconds(currentItem.currentTime())
        }
        
        return nil
    }
}
