//
//  HomeView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 2.10.2023.
//

import SwiftUI
import AVFoundation
import SwiftData

struct HomeView: View {
    @StateObject private var audioPlayer = AudioPlayer()
    @Environment(\.modelContext) private var modelContext
    @Query private var songs: [Track]
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredSongs) { item in
                    Button(action: {
                        audioPlayer.play(url: item.path)
                    }, label: {
                        Text(item.title)
                            .font(.title)
                    })
                    .buttonStyle(.borderless)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Home")
            .searchable(text: $searchText, prompt: "Search song")
            .overlay(alignment: .bottom) {
                SeekbarView(
                    current: Binding(
                        get: { audioPlayer.player.currentDuration ?? 0 },
                        set: { newValue in
                            let cmTime = CMTime(seconds: newValue, preferredTimescale: 1)

                            audioPlayer.player.seek(to: cmTime)
                        }
                    ),
                    duration: Binding(
                        get: { audioPlayer.player.duration ?? 0 },
                        set: { newValue in
                            // Handle setting the duration of the player if needed
                        }
                    ),
                    isPlaying: Binding(
                        get: { audioPlayer.player.isPlaying },
                        set: { newValue in
                            // Handle setting the duration of the player if needed
                        }
                    )
                )
                
            }
            .toolbar {
                ToolbarItem {
                    Button(action: scanFolder) {
                        Label("Scan", systemImage: "folder.fill.badge.plus")
                    }
                }
            }
        }
    }
    
    private var filteredSongs: [Track] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func scanFolder() {
        let folderAnalyzer = FolderAnalyzer()
        folderAnalyzer.browse { folderUrl in
            guard let urls = try? FileManager.default.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: nil, options: []) else {
                return
            }
            
            let fileAnalyzer = FileAnalyzer()
            
            for url in urls {
                let title = url.lastPathComponent
                
                if let metadata = fileAnalyzer.getMetadata(url: url) {
                    let artist = metadata["artist"] as? String ?? "Unknown"
                    let album = metadata["album"] as? String ?? "Unknown"
                    let length = metadata["approximate duration in seconds"] as? Double ?? 0.0
                    
                    let track = Track(title: title, artist: artist, album: album, length: length, path: url)
                    
                    modelContext.insert(track)
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(songs[index])
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Track.self, inMemory: true)
}
