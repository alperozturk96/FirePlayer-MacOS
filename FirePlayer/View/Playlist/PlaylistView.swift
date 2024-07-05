//
//  PlaylistView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 05.07.24.
//

import SwiftUI


struct PlaylistView: View {
    
    var audioPlayer: AudioPlayer
    var tracks: [Track]
    
    @State private var showSeekbar = false
    
    var body: some View {
        List {
            ForEach(Array(tracks.enumerated()), id: \.offset) { index, item in
                Button {
                    audioPlayer.changeIndex(index)
                    
                    if !showSeekbar {
                        showSeekbar = true
                    }
                } label: {
                    Text(item.title)
                        .font(.title)
                        .foregroundStyle(index == audioPlayer.selectedTrackIndex ? .yellow.opacity(0.8) : .white)
                }
                .buttonStyle(.borderless)
            }
        }
        .overlay(alignment: .bottom) {
            if showSeekbar {
                SeekbarView(audioPlayer)
            }
        }
    }
}
