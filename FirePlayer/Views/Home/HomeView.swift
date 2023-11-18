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
                        // TODO Highlight selected track
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
            .navigationTitle("home_navigation_bar_title")
            .searchable(text: $searchText, prompt: "home_searchable_prompt")
            .overlay(alignment: .bottom) {
                if selectedIndex != nil {
                    SeekbarView(selectedTrackIndex: $selectedIndex, tracks: filteredTracks)
                }
            }
            .onChange(of: searchText) {
               search()
            }
            .confirmationDialog("home_filter_confirmation_dialog_title", isPresented: $showFilterOptions) {
                Button("home_filter_dialog_filter_by_title_title") {
                    filterOption = .title
                }
                Button("home_filter_dialog_filter_by_artist_title") {
                    filterOption = .artist
                }
                Button("home_filter_dialog_filter_by_album_title") {
                    filterOption = .album
                }
            }
            .confirmationDialog("home_sort_confirmation_dialog_title", isPresented: $showSortOptions) {
                Button("home_sort_dialog_sort_by_title_a_z_title") {
                    filteredTracks = filteredTracks.sortByTitleAZ()
                }
                Button("home_sort_dialog_sort_by_title_z_a_title") {
                    filteredTracks = filteredTracks.sortByTitleZA()
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { showFilterOptions = true }) {
                        Label("home_toolbar_filter_title", systemImage: "ellipsis.viewfinder")
                    }
                }
                ToolbarItem {
                    Button(action: { showSortOptions = true }) {
                        Label("home_toolbar_sort_title", systemImage: "line.3.horizontal")
                    }
                }
                ToolbarItem {
                    Button(action: scanFolder) {
                        Label("home_toolbar_scan_title", systemImage: "folder.fill.badge.plus")
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
        
        for url in urls.supportedUrls {
            let title = url.lastPathComponent
            
            var track = Track(title: title, artist: "", album: "", length: 0.0, path: url, pathExtension: url.pathExtension)

            if let metadata = trackMetaDataAnalyzer.getMetadata(url: url) {
                track.artist = metadata["artist"] as? String ?? "Unknown"
                track.album = metadata["album"] as? String ?? "Unknown"
                track.length = metadata["approximate duration in seconds"] as? Double ?? 0.0
            }
            
            tracks.append(track)
        }
        
        filteredTracks = tracks.sortByTitleAZ()
        print("Total Track Counts: ", filteredTracks.count)
    }
}

#Preview {
    HomeView()
}
