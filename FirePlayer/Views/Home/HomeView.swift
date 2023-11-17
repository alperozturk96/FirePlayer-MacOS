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
    private let userService = UserService()
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Track.title) private var tracks: [Track]
    
    @State private var filteredTracks = [Track]()
    @State private var showSortOptions = false
    @State private var url: URL?
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTracks) { item in
                    Button(action: {
                        // FIXME Increase song switch performance, selected song seek to not working
                        url = item.path
                    }, label: {
                        Text(item.title)
                            .font(.title)
                    })
                    .buttonStyle(.borderless)
                }
                .onDelete(perform: deleteItems)
            }
            .onAppear {
                scanSavedFolderURL()
            }
            .navigationTitle("Home")
            .searchable(text: $searchText, prompt: "Search song")
            .overlay(alignment: .bottom) {
                if let url {
                    SeekbarView(url: url)
                }
            }
            .onChange(of: searchText) {
                if searchText.isEmpty {
                    filteredTracks = tracks
                } else {
                    filteredTracks = tracks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
                }
            }
            .confirmationDialog("Sort", isPresented: $showSortOptions) {
                Button("Sort By Title AZ") {
                    filteredTracks = filteredTracks.sortByTitleAZ()
                }
                Button("Sort By Title ZA") {
                    filteredTracks = filteredTracks.sortByTitleZA()
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { showSortOptions = true }) {
                        Label("Sort", systemImage: "line.3.horizontal")
                    }
                }
                ToolbarItem {
                    Button(action: scanFolder) {
                        Label("Scan", systemImage: "folder.fill.badge.plus")
                    }
                }
            }
        }
    }
}

// MARK: - Private Methods
extension HomeView {
    private func scanSavedFolderURL() {
        guard let url = userService.readFolderURL() else {
            return
        }
        
        addTracksFromGiven(folderURL: url)
    }
    
    private func scanFolder() {
        let folderAnalyzer = FolderAnalyzer()
        folderAnalyzer.browse { url in
            addTracksFromGiven(folderURL: url)
            userService.saveFolderURL(url: url)
        }
    }
    
    private func addTracksFromGiven(folderURL: URL) {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: []) else {
            return
        }
        
        let trackMetaDataAnalyzer = TrackMetaDataAnalyzer()
        
        for url in urls {
            let title = url.lastPathComponent
            
            if let metadata = trackMetaDataAnalyzer.getMetadata(url: url) {
                let artist = metadata["artist"] as? String ?? "Unknown"
                let album = metadata["album"] as? String ?? "Unknown"
                let length = metadata["approximate duration in seconds"] as? Double ?? 0.0
                
                let track = Track(title: title, artist: artist, album: album, length: length, path: url)
                
                modelContext.insert(track)
            }
        }
        
        filteredTracks = tracks
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredTracks[index])
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Track.self, inMemory: true)
}
