//
//  AudioPlayer.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 10.10.2023.
//

import Foundation
import AVFoundation

final class AudioPlayer {
    
    static var shared = AudioPlayer()
    private var player = AVPlayer()
    
    private init() {}
    
    func play(url: URL) {
        print("Path: ", url)
        player = AVPlayer(url: url)
        player.volume = 1
        player.play()
    }
}
