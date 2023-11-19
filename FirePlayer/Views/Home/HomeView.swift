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
    @State private var filteredTracksByArtist = [Track]()
    @State private var filteredTracksByAlbum = [Track]()
    @State private var filteredTracksByTitle = [Track]()
    @State private var selectedFilterOption: FilterOptions = .title
    @State private var showSortOptions = false
    @State private var selectedIndex: Int?
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                TrackSection(title: "home_filter_by_title_section_title".localized, data: filteredTracksByTitle, filterOption: .title)
                TrackSection(title: "home_filter_by_artist_section_title".localized, data: filteredTracksByArtist, filterOption: .artist)
                TrackSection(title: "home_filter_by_album_section_title".localized, data: filteredTracksByAlbum, filterOption: .album)
            }
            .onAppear {
                scanSavedFolderURL()
            }
            .navigationTitle("home_navigation_bar_title")
            .searchable(text: $searchText, prompt: "home_searchable_prompt")
            .overlay(alignment: .bottom) {
                SeekBar
            }
            .onChange(of: searchText) {
               search()
            }
            .confirmationDialog("home_sort_confirmation_dialog_title", isPresented: $showSortOptions) {
                SortConfirmationButtons
            }
            .toolbar {
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

// MARK: - ChildViews
extension HomeView {
    private func TrackSection(title: String, data: [Track], filterOption: FilterOptions) -> some View {
        Section(header: Text(title)) {
            TrackList(data: data, filterOption: filterOption)
        }
    }
    
    private func TrackList(data: [Track], filterOption: FilterOptions) -> some View {
        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
            Button(action: {
                selectedIndex = index
                selectedFilterOption = filterOption
            }, label: {
                Text(item.title)
                    .font(.title)
            })
            .buttonStyle(.borderless)
        }
    }
    
    @ViewBuilder
    private var SortConfirmationButtons: some View {
        Button("home_sort_dialog_sort_by_title_a_z_title") {
            filteredTracksByTitle = filteredTracksByTitle.sortByTitleAZ()
            filteredTracksByAlbum = filteredTracksByAlbum.sortByTitleAZ()
            filteredTracksByArtist = filteredTracksByArtist.sortByTitleAZ()
        }
        Button("home_sort_dialog_sort_by_title_z_a_title") {
            filteredTracksByTitle = filteredTracksByTitle.sortByTitleZA()
            filteredTracksByAlbum = filteredTracksByAlbum.sortByTitleZA()
            filteredTracksByArtist = filteredTracksByArtist.sortByTitleZA()
        }
    }
    
    @ViewBuilder
    private var SeekBar: some View {
        if selectedIndex != nil {
            let data: [Track] = switch selectedFilterOption {
            case .title:
                filteredTracksByTitle
            case .artist:
                filteredTracksByArtist
            case .album:
                filteredTracksByAlbum
            }
            
            SeekbarView(selectedTrackIndex: $selectedIndex, tracks: data)
        }
    }
}

// MARK: - Private Methods
extension HomeView {
    private func search() {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if searchText.isEmpty {
                filteredTracksByTitle = tracks.sortByTitleAZ()
            } else {
                filteredTracksByAlbum = tracks.filterByAlbum(album: searchText).sortByTitleAZ()
                filteredTracksByArtist = tracks.filterByArtist(artist: searchText).sortByTitleAZ()
                filteredTracksByTitle = tracks.filterByTitle(title: searchText).sortByTitleAZ()
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
        
        filteredTracksByTitle = tracks.sortByTitleAZ()
        print("Total Track Counts: ", filteredTracksByTitle.count)
    }
}

#Preview {
    HomeView()
}
