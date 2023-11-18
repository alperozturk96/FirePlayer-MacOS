//
//  HomeView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 2.10.2023.
//

import SwiftUI

struct HomeView: View {
    private let userService = UserService()
    
    @State private var searchTimer: Timer?
    
    @State private var tracks = [Track]()
    @State private var filteredTracks = [Track]()
    @State private var filterOption = FilterOptions.title
    @State private var showSortOptions = false
    @State private var showFilterOptions = false
    @State private var selectedIndex: Int?
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(filteredTracks.enumerated()), id: \.offset) { index, item in
                    Button(action: {
                        selectedIndex = index
                    }, label: {
                        Text(item.title)
                            .font(.title)
                    })
                    .buttonStyle(.borderless)
                }
            }
            .onAppear {
                scanSavedFolderURL()
            }
            .navigationTitle("FirePlayer")
            .searchable(text: $searchText, prompt: "Search song")
            .overlay(alignment: .bottom) {
                if selectedIndex != nil {
                    SeekbarView(selectedTrackIndex: $selectedIndex, tracks: filteredTracks)
                }
            }
            .onChange(of: searchText) {
               search()
            }
            .confirmationDialog("Filter", isPresented: $showFilterOptions) {
                Button("Filter By Title") {
                    filterOption = .title
                }
                Button("Filter By Artist") {
                    filterOption = .artist
                }
                Button("Filter By Album") {
                    filterOption = .album
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
                    Button(action: { showFilterOptions = true }) {
                        Label("Filter", systemImage: "ellipsis.viewfinder")
                    }
                }
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
    private func search() {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if searchText.isEmpty {
                filteredTracks = tracks.sortByTitleAZ()
            } else {
                let result = switch filterOption {
                    case .title: tracks.filterByTitle(title: searchText)
                    case .artist: tracks.filterByArtist(artist: searchText)
                    case .album: tracks.filterByAlbum(album: searchText)
                }
                filteredTracks = result.sortByTitleAZ()
            }
        }
    }
    
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
                tracks.append(track)
            }
        }
        
        filteredTracks = tracks.sortByTitleAZ()
    }
}

#Preview {
    HomeView()
}
