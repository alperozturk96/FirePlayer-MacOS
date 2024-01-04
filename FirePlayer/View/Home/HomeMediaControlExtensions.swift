//
//  HomeMediaControlExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 21.11.2023.
//

import Foundation

extension HomeView {
    func setupPlayerEvents() {
        receive(event: .previous) {
            selectPreviousTrack()
        }
        
        receive(event: .toggle) {
            audioPlayer.player.toggle()
        }
        
        receive(event: .next) {
            selectNextTrack()
        }
    }
    
    func removeObservers() {
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
