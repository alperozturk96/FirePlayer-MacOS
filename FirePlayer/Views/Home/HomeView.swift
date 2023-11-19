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
    @State private var playMode: PlayMode = .shuffle
    @State private var selectedFilterOption: FilterOptions = .title
    @State private var showSortOptions = false
    @State private var selectedTrackIndex: Int = -1
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    Section(header: Text(header)) {
                        TrackList(data: filteredTracks, proxy: proxy)
                    }
                }
                .onChange(of: selectedTrackIndex) {
                    scrollToSelectedTrack(proxy: proxy)
                }
            }
            .onAppear {
                scanSavedFolderURL()
            }
            .navigationTitle("home_navigation_bar_title")
            .searchable(text: $searchText, prompt: searchPrompt)
            .overlay(alignment: .bottom) {
                SeekBar
            }
            .onChange(of: searchText) {
                search()
            }
            .onChange(of: selectedFilterOption) {
                search()
            }
            .confirmationDialog("home_sort_confirmation_dialog_title", isPresented: $showSortOptions) {
                SortConfirmationButtons
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        if selectedFilterOption == .title {
                            selectedFilterOption = .artist
                        } else if selectedFilterOption == .artist {
                            selectedFilterOption = .album
                        } else {
                            selectedFilterOption = .title
                        }
                    }) {
                        let systemImage = switch selectedFilterOption {
                        case .title:
                            "textformat.alt"
                        case .artist:
                            "person.fill"
                        case .album:
                            "rectangle.stack.fill"
                        }
                        Label("home_toolbar_filter_option_title", systemImage: systemImage)
                    }
                }
                ToolbarItem {
                    Button(action: {
                        playMode = (playMode == .shuffle) ? .sequential : .shuffle
                    }) {
                        Label("home_toolbar_play_mode_title", systemImage: playMode == .shuffle ? "shuffle.circle.fill" : "arrow.forward.to.line.circle.fill")
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

// MARK: - ChildViews
extension HomeView {
    private func TrackList(data: [Track], proxy: ScrollViewProxy) -> some View {
        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
            Button(action: {
                selectedTrackIndex = index
                scrollToSelectedTrack(proxy: proxy)
                publish(event: .play)
            }, label: {
                // FIXME highlight is broken when user have result more than one section
                Text(item.title)
                    .font(.title)
                    .foregroundStyle(index == selectedTrackIndex ? .yellow.opacity(0.8) : .white)
            })
            .buttonStyle(.borderless)
        }
    }
    
    @ViewBuilder
    private var SortConfirmationButtons: some View {
        Button("home_sort_dialog_sort_by_title_a_z_title") {
            filteredTracks = filteredTracks.sortByTitleAZ()
        }
        Button("home_sort_dialog_sort_by_title_z_a_title") {
            filteredTracks = filteredTracks.sortByTitleZA()
        }
    }
    
    @ViewBuilder
    private var SeekBar: some View {
        if selectedTrackIndex != -1 {
            SeekbarView(playMode: $playMode, selectedTrackIndex: $selectedTrackIndex, tracks: filteredTracks)
        }
    }
    
    var header: String {
        return switch selectedFilterOption {
        case .title:
            "home_filter_by_title_section_title".localized
        case .artist:
            "home_filter_by_artist_section_title".localized
        case .album:
            "home_filter_by_album_section_title".localized
        }
    }
    
    var searchPrompt: String {
        return switch selectedFilterOption {
        case .title:
            "home_search_in_title_prompt".localized
        case .artist:
            "home_search_in_artists_prompt".localized
        case .album:
            "home_search_in_albums_prompt".localized
        }
    }
}

// MARK: - Private Methods
extension HomeView {
    private func scrollToSelectedTrack(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(selectedTrackIndex, anchor: .center)
        }
    }
    
    private func search() {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if searchText.isEmpty {
                filteredTracks = tracks.sortByTitleAZ()
            } else {
                filteredTracks = switch selectedFilterOption {
                case .title:
                    tracks.filterByTitle(title: searchText).sortByTitleAZ()
                case .artist:
                    tracks.filterByArtist(artist: searchText).sortByTitleAZ()
                case .album:
                    tracks.filterByAlbum(album: searchText).sortByTitleAZ()
                }
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
            
            var track = Track(title: title, artist: "", album: "", path: url, pathExtension: url.pathExtension)
            
            if let metadata = trackMetaDataAnalyzer.getMetadata(url: url) {
                track.artist = metadata["artist"] as? String ?? "Unknown"
                track.album = metadata["album"] as? String ?? "Unknown"
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
