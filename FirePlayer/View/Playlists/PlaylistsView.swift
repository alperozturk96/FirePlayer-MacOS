//
//  PlaylistsView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 21.11.2023.
//

import SwiftUI
import SwiftData

struct PlaylistsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var audioPlayer: AudioPlayer
    
    @Query private var playlists: [Playlist]
    
    @State private var showAddPlaylist = false
    @State private var playlistText: String = ""
    
    var body: some View {
        Group {
            if playlists.isEmpty {
                ContentUnavailableView(AppTexts.playlistUnavailable, systemImage: AppIcons.star, description: Text(AppTexts.playlistContentUnavailable))
                    .symbolVariant(.slash)
            } else {
                List {
                    ForEach(playlists) { playlist in
                        NavigationLink {
                            PlaylistView(audioPlayer: audioPlayer, tracks: playlist.tracks)
                        } label: {
                            Text(playlist.name)
                                .font(.title)
                                .swipeActions {
                                    Button {
                                        modelContext.delete(playlist)
                                    } label: {
                                        Text(AppTexts.playlistTrackSwipeTitle)
                                    }
                                    .tint(.red)
                                }
                        }
                        .contextMenu {
                            Button(AppTexts.deletePlaylist) {
                                modelContext.delete(playlist)
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                AddPlaylistButton
            }
        }
        .confirmationDialog(AppTexts.addPlaylistTitle, isPresented: $showAddPlaylist) {
            AddPlaylistTextField
        }
    }
}

// MARK: - ChildViews
extension PlaylistsView {
    private var AddPlaylistTextField: some View {
        VStack {
            TextField(AppTexts.addPlaylistPlaceholder, text: $playlistText)
            Button(AppTexts.ok) {
                let newPlaylist = Playlist(name: playlistText, tracks: .init())
                modelContext.insert(newPlaylist)
                showAddPlaylist = false
            }
        }
    }
    
    private var AddPlaylistButton: some View {
        Button(action: { showAddPlaylist = true }) {
            Label(AppTexts.addPlaylistButton, systemImage: AppIcons.addPlaylist)
        }
    }
}
