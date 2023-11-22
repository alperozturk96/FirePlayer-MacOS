//
//  PlaylistsView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 21.11.2023.
//

import SwiftUI

struct PlaylistsView: View {
    @Environment(\.dismiss) var dismiss
    
    var mode: PlaylistsViewMode
    var selectedTrackIndex: Int?
    @Binding var playlists: [String: [Int]]
    @Binding var filteredTracks: [Track]
    let userService: UserService
    
    @State private var showAddPlaylist = false
    @State private var playlistText: String = ""
    
    var body: some View {
        Group {
            if playlists.isEmpty {
                ContentUnavailableView("No playlists", systemImage: "star", description: Text("You don't have any playlist yet."))
                    .symbolVariant(.slash)
            } else {
                List {
                    // TODO add remove capability
                    ForEach(playlists.keys.sorted(), id: \.self) { title in
                        Button(title) {
                            if mode == .add {
                                if let selectedTrackIndex {
                                    playlists[title, default: []].append(selectedTrackIndex)
                                }
                            } else {
                                filteredTracks = filterTracks(forPlaylist: title)
                            }
                            
                            dismiss()
                        }
                    }
                }
            }
        }
        .onDisappear {
            updatePlaylist()
        }
        .toolbar {
            ToolbarItem {
                AddPlaylistButton
            }
        }
        .confirmationDialog("home_playlist_confirmation_dialog_title", isPresented: $showAddPlaylist) {
            AddPlaylistTextField
        }
    }
}

// MARK: - Private Methods
extension PlaylistsView {
    private func filterTracks(forPlaylist playlistName: String) -> [Track] {
        guard let trackIndexes = playlists[playlistName] else {
            return []
        }
        
        let result = trackIndexes.compactMap { index -> Track? in
            guard filteredTracks.indices.contains(index) else { return nil }
            return filteredTracks[index]
        }
        
        return result
    }
    
    private func updatePlaylist() {
        userService.savePlaylist(playlists: playlists)
    }
}

// MARK: - ChildViews
extension PlaylistsView {
    private var AddPlaylistTextField: some View {
        VStack {
            TextField("home_add_playlist_placeholder".localized, text: $playlistText)
            Button("common_ok".localized) {
                playlists[playlistText] = .init()
                updatePlaylist()
            }
        }
    }
    
    private var AddPlaylistButton: some View {
        Button(action: { showAddPlaylist = true }) {
            Label("home_toolbar_add_playlist_title".localized, systemImage: "doc.fill.badge.plus")
        }
    }
}
