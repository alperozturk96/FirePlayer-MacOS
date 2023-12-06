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
    
    @StateObject var audioPlayerService = AudioPlayerService.shared
    
    @State var prevTrackIndexesStack: [Int] = []
    @State var filteredTracks = [Track]()
    @State var playMode: PlayMode = .shuffle
    @State var selectedTrackIndex: Int = 0
    
    @State private var playlists: [String: [Int]] = [:]
    @State private var tracks = [Track]()
    @State private var selectedFilterOption: FilterOptions = .title
    @State private var sortOption: SortOptions = .aToZ
    @State private var showSeekbar = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                TracksButton
                PlaylistsButton
            }
            .listStyle(SidebarListStyle())
            
            Group {
                if filteredTracks.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ScrollViewReader { proxy in
                        List {
                            Section(header: Header) {
                                TrackList(data: filteredTracks, proxy: proxy)
                            }
                        }
                        .onChange(of: selectedTrackIndex) {
                            scrollToSelectedTrack(proxy: proxy)
                        }
                    }
                    .overlay(alignment: .bottom) {
                        SeekBar
                    }
                }
            }
            .navigationTitle(AppTexts.homeNavBarTitle)
            .onAppear {
                readPreviouslySavedPlaylists()
                scanPreviouslySelectedFolder()
                setupPlayerEvents()
            }
            .onDisappear {
                removeObservers()
            }
            .searchable(text: $searchText, prompt: selectedFilterOption.searchPrompt)
            .onChange(of: searchText) {
                search()
            }
            .onChange(of: selectedFilterOption) {
                search()
            }
            .onChange(of: sortOption) {
                filteredTracks = filteredTracks.sort(sortOption)
            }
            .onChange(of: selectedTrackIndex) {
                playSelectedTrack()
            }
            .toolbar {
                ToolbarItem {
                    FilterOptionsButton
                }
                ToolbarItem {
                    PlayModeButton
                }
                ToolbarItem {
                    SortButton
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
    private var Header: some View {
        Text(selectedFilterOption.header)
    }
    
    private func TrackList(data: [Track], proxy: ScrollViewProxy) -> some View {
        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
            Button {
                trackButtonAction(index)
            } label: {
                // FIXME highlight is broken when user have result more than one section
                Text(item.title)
                    .font(.title)
                    .foregroundStyle(index == selectedTrackIndex ? .yellow.opacity(0.8) : .white)
                    .swipeActions {
                        NavigationLink {
                            PlaylistsView(mode: .add, selectedTrackIndex: index, playlists: $playlists, filteredTracks: $filteredTracks, userService: userService)
                        } label: {
                            Text(AppTexts.homeTrackSwipeTitle)
                        }
                    }
            }
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
    private var PlayModeButton: some View {
        Button {
            playMode = playMode.next
        } label: {
            Label(AppTexts.playModeTitle, systemImage: playMode.icon)
        }
    }
    
    private var SortButton: some View {
        Button {
            sortOption = sortOption.next
        } label: {
            Label(AppTexts.playModeTitle, systemImage: sortOption.icon)
        }
    }
    
    private var FilterOptionsButton: some View {
        Button {
            selectedFilterOption = selectedFilterOption.next
        } label: {
            Label(AppTexts.filterOptionTitle, systemImage: selectedFilterOption.icon)
        }
    }
    
    private var TracksButton: some View {
        Label(AppTexts.tracks, systemImage: AppIcons.tracks)
            .onTapGesture {
                withAnimation {
                    resetFilteredTracks()
                }
            }
    }
    
    private var PlaylistsButton: some View {
        NavigationLink {
            PlaylistsView(mode: .select, selectedTrackIndex: nil, playlists: $playlists, filteredTracks: $filteredTracks, userService: userService)
        } label: {
            Label(AppTexts.playlists, systemImage: AppIcons.playlists)
        }
    }
    
    private var ScanFolderButton: some View {
        Button(action: scanFolder) {
            Label(AppTexts.scan, systemImage: AppIcons.folder)
        }
    }
}

// MARK: - Private Methods
extension HomeView {
    private func trackButtonAction(_ index: Int) {
        if index == selectedTrackIndex {
            playSelectedTrack()
        } else {
            selectedTrackIndex = index
        }
        
        if !showSeekbar {
            showSeekbar = true
        }
    }
    
    private func playSelectedTrack() {
        audioPlayerService.play(url: filteredTracks[selectedTrackIndex].path)
        prevTrackIndexesStack.append(selectedTrackIndex)
    }
    
    private func scrollToSelectedTrack(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(selectedTrackIndex, anchor: .center)
        }
    }
    
    private func resetFilteredTracks() {
        filteredTracks = tracks
        searchText = ""
    }
    
    private func search() {
        filteredTracks = if searchText.isEmpty {
            tracks
        } else {
            tracks.filter(selectedFilterOption, text: searchText).sort(.aToZ)
        }
    }
    
    private func scanPreviouslySelectedFolder() {
        guard tracks.isEmpty else { return }
        
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
            tracks.append(url.toTrack(trackMetaDataAnalyzer))
        }
        
        tracks = tracks.sort(.aToZ)
        filteredTracks = tracks
        AppLogger.shared.info("Total Track Counts: \(filteredTracks.count)")
    }
}

#Preview {
    HomeView()
}
