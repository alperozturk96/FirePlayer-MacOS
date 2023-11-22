//
//  HomeView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 2.10.2023.
//

import SwiftUI
import OSLog

struct HomeView: View {
    private let trackMetaDataAnalyzer = TrackMetaDataAnalyzer()
    private let folderAnalyzer = FolderAnalyzer()
    private let userService = UserService()
    
    @StateObject var audioPlayerService = AudioPlayerService()
    
    @State var playerItemObserver: Any?
    @State var prevTrackIndexesStack: [Int] = []
    @State var filteredTracks = [Track]()
    @State var playMode: PlayMode = .shuffle
    @State var selectedTrackIndex: Int = 0
    
    @State private var playlists: [String: [Int]] = [:]
    @State private var tracks = [Track]()
    @State private var selectedFilterOption: FilterOptions = .title
    @State private var showSeekbar = false
    @State private var showSortOptions = false
    @State private var searchText = ""
    
    // TODO add clear filtered tracks for playlist
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                if filteredTracks.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        Section(header: Text(header)) {
                            TrackList(data: filteredTracks, proxy: proxy)
                        }
                    }
                    .onChange(of: selectedTrackIndex) {
                        scrollToSelectedTrack(proxy: proxy)
                    }
                }
            }
            .onAppear {
                readPreviouslySavedPlaylists()
                scanPreviouslySelectedFolder()
                observePlayerStatus()
                setupPlayerEvents()
            }
            .onDisappear {
                removeObservers()
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
            .onChange(of: selectedTrackIndex) {
                playSelectedTrack()
            }
            .confirmationDialog("home_sort_confirmation_dialog_title", isPresented: $showSortOptions) {
                SortConfirmationButtons
            }
            .toolbar {
                ToolbarItem {
                    FilterOptionsButton
                }
                ToolbarItem {
                    ShowPlaylistsButton
                }
                ToolbarItem {
                    PlayModeButton
                }
                ToolbarItem {
                    SortOptionsButton
                }
                ToolbarItem {
                    ScanFolderButton
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
                
                if !showSeekbar {
                    showSeekbar = true
                }
            }, label: {
                // FIXME highlight is broken when user have result more than one section
                Text(item.title)
                    .font(.title)
                    .foregroundStyle(index == selectedTrackIndex ? .yellow.opacity(0.8) : .white)
                    .swipeActions {
                        NavigationLink {
                            PlaylistsView(mode: .add, selectedTrackIndex: index, playlists: $playlists, filteredTracks: $filteredTracks, userService: userService)
                        } label: {
                            Text("home_list_swipe_action_title".localized)
                                .tint(.orange)
                        }
                    }
            })
            .buttonStyle(.borderless)
        }
    }
    
    @ViewBuilder
    private var SeekBar: some View {
        if showSeekbar {
            SeekbarView(audioPlayerService: audioPlayerService, selectPreviousTrack: selectPreviousTrack, selectNextTrack: selectNextTrack)
        }
    }
}

// MARK: - Buttons
extension HomeView {
    @ViewBuilder
    private var SortConfirmationButtons: some View {
        Button("home_sort_dialog_sort_by_title_a_z_title") {
            filteredTracks = filteredTracks.sortByTitleAZ()
        }
        Button("home_sort_dialog_sort_by_title_z_a_title") {
            filteredTracks = filteredTracks.sortByTitleZA()
        }
    }
    
    private var PlayModeButton: some View {
        Button(action: {
            playMode = (playMode == .shuffle) ? .sequential : .shuffle
        }) {
            Label("home_toolbar_play_mode_title".localized, systemImage: playMode == .shuffle ? "shuffle.circle.fill" : "arrow.forward.to.line.circle.fill")
        }
    }
    
    private var FilterOptionsButton: some View {
        Button(action: {
            selectedFilterOption = (selectedFilterOption == .title) ? .artist : (selectedFilterOption == .artist) ? .album : .title
        }) {
            let systemImage = switch selectedFilterOption {
            case .title:
                "textformat.alt"
            case .artist:
                "person.fill"
            case .album:
                "rectangle.stack.fill"
            }
            
            Label("home_toolbar_filter_option_title".localized, systemImage: systemImage)
        }
    }
    
    private var ShowPlaylistsButton: some View {
        NavigationLink {
            PlaylistsView(mode: .select, selectedTrackIndex: nil, playlists: $playlists, filteredTracks: $filteredTracks, userService: userService)
        } label: {
            Label("home_toolbar_show_playlists_title".localized, systemImage: "star.fill")
        }
    }
    
    private var SortOptionsButton: some View {
        Button(action: { showSortOptions = true }) {
            Label("home_toolbar_sort_title".localized, systemImage: "line.3.horizontal")
        }
    }
    
    private var ScanFolderButton: some View {
        Button(action: scanFolder) {
            Label("home_toolbar_scan_title".localized, systemImage: "folder.fill.badge.plus")
        }
    }
}

// MARK: - Texts
extension HomeView {
    private var header: String {
        return switch selectedFilterOption {
        case .title:
            "home_filter_by_title_section_title".localized
        case .artist:
            "home_filter_by_artist_section_title".localized
        case .album:
            "home_filter_by_album_section_title".localized
        }
    }
    
    private var searchPrompt: String {
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
    private func playSelectedTrack() {
        audioPlayerService.play(url: filteredTracks[selectedTrackIndex].path)
        prevTrackIndexesStack.append(selectedTrackIndex)
    }
    
    private func scrollToSelectedTrack(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(selectedTrackIndex, anchor: .center)
        }
    }
    
    private func search() {
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
    
    private func scanPreviouslySelectedFolder() {
        guard let url = userService.readFolderURL() else {
            return
        }
        
        addTracksFromGiven(folderURL: url)
    }
    
    private func readPreviouslySavedPlaylists() {
        playlists = userService.readPlaylists()
    }
    
    private func scanFolder() {
        folderAnalyzer.browse { url in
            addTracksFromGiven(folderURL: url)
            userService.saveFolderURL(url: url)
        }
    }
    
    private func addTracksFromGiven(folderURL: URL) {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: []) else {
            return
        }
        
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
        AppLogger.shared.info("Total Track Counts: \(filteredTracks.count)")
    }
}

#Preview {
    HomeView()
}
