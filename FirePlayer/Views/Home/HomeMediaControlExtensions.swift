//
//  HomeMediaControlExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 21.11.2023.
//

import Foundation

extension HomeView {
    func observePlayerStatus() {
        playerItemObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: audioPlayerService.player.currentItem,
            queue: nil) { _ in
                selectNextTrack()
            }
    }
    
    func setupPlayerEvents() {
        receive(event: .previous) {
            selectPreviousTrack()
        }
        
        receive(event: .playerToggle) {
            audioPlayerService.player.toggle()
        }
        
        receive(event: .next) {
            selectNextTrack()
        }
    }
    
    func removeObservers() {
        if let observer = playerItemObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func selectPreviousTrack() {
        guard prevTrackIndexesStack.count > 1 else { return }
        _ = prevTrackIndexesStack.popLast()
        
        if let prevIndex = prevTrackIndexesStack.last {
            selectedTrackIndex = prevIndex
        }
    }
    
    func selectNextTrack() {
        let nextIndex = (playMode == .shuffle) ? filteredTracks.randomIndex : (selectedTrackIndex < filteredTracks.count) ? selectedTrackIndex + 1 : 0
        selectedTrackIndex = nextIndex
    }
}
