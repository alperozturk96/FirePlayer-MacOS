//
//  TrackList.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 05.07.24.
//

import SwiftUI

extension HomeView {
    func TrackList(proxy: ScrollViewProxy) -> some View {
        ForEach(Array(audioPlayer.filteredTracks.enumerated()), id: \.offset) { index, item in
            TrackListItem(index, item)
        }
    }
    
    private func TrackListItem(_ index: Int, _ item: Track) -> some View {
        Button {
            trackButtonAction(index)
        } label: {
            // FIXME highlight is broken when user have result more than one section
            Text(item.title)
                .font(.title)
                .foregroundStyle(index == audioPlayer.selectedTrackIndex ? .yellow.opacity(0.8) : .white)
        }
        .buttonStyle(.borderless)
        .contextMenu {
            Button(AppTexts.addToPlaylist) {
                showAddToPlaylistSheet = true
            }
            Button(AppTexts.saveTrackPosition) {
                audioPlayer.saveTrackPlaybackPosition(id: item.id)
            }
            Button(AppTexts.resetTrackPosition) {
                audioPlayer.removeTrackPlaybackPosition(id: item.id)
            }
            Button(AppTexts.deleteTrack) {
                selectedTrackForFileActions = item
                showDeleteAlert = true
            }
        }
    }
    
    func trackButtonAction(_ index: Int) {
        audioPlayer.changeIndex(index)
        
        if !showSeekbar {
            showSeekbar = true
        }
        
        if showLoadingIndicator {
            showLoadingIndicator = false
        }
    }
}
