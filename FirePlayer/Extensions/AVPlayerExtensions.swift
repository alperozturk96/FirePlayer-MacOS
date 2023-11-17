//
//  AudioPlayer.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 10.10.2023.
//

import Foundation
import AVFoundation

extension AVPlayer {
    func toggle() {
        isPlaying ? pause() : play()
    }
    
    var isPlaying: Bool {
        rate != 0 && error == nil
    }
}
