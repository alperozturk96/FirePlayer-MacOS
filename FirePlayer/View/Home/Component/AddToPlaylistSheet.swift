//
//  AddToPlaylistSheet.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 05.07.24.
//

import SwiftUI

extension HomeView {
    func AddToPlaylistSheet() -> some View {
        return List {
            ForEach(Array(playlists.enumerated()), id: \.offset) { index, playlist in
                Button {
                    if let selectedTrackForFileActions {
                        playlist.tracks.append(selectedTrackForFileActions)
                        modelContext.insert(playlist)
                    }
                } label: {
                    Text(playlist.name)
                        .font(.title)
                        .foregroundStyle( .white)
                }
                .buttonStyle(.borderless)
                
                Divider()
            }
        }
    }
}
