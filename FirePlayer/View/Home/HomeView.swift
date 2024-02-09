//
//  HomeView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 2.10.2023.
//

import SwiftUI
import OSLog

struct HomeView: View {
    private let fileUtil = FileUtil()
    let userService = UserService()
    
    @StateObject var audioPlayer = AudioPlayer.shared
    
    @State var prevTrackIndexesStack: [Int] = []
    @State var filteredTracks = [Track]()
    @State var playMode: PlayMode = .shuffle
    @State var selectedTrackIndex: Int = 0
    
    @State private var playlists: [String: [Int]] = [:]
    @State private var tracks = [Track]()
    @State private var selectedFilterOption: FilterOptions = .title
    @State private var sortOption: SortOptions = .aToZ
    @State private var showSeekbar = false
    @State private var showSortOptions = false
    @State private var searchText = ""
    @State private var selectedTrackForFileActions: Track?
    @State private var showDeleteAlert = false
    
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
                            Section(header: Text(selectedFilterOption.header)) {
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
            .confirmationDialog(AppTexts.sortOptionsTitle, isPresented: $showSortOptions) {
                Button(AppTexts.sortByTitle) {
                    sortOption = sortOption.sortByTitle()
                }
                Button(AppTexts.sortByDate) {
                    sortOption = sortOption.sortByDate()
                }
                Button(AppTexts.cancel, role: .cancel) { showSortOptions = false }
            }
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
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text(AppTexts.deleteAlertTitle),
                    message: Text(AppTexts.deleteAlertDescription),
                    primaryButton: .destructive(Text(AppTexts.ok)) {
                        if let selectedTrackForFileActions {
                            fileUtil.deleteFile(url: selectedTrackForFileActions.path) {
                                filteredTracks.remove(selectedTrackForFileActions)
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// MARK: - ChildViews
extension HomeView {
    private func TrackList(data: [Track], proxy: ScrollViewProxy) -> some View {
        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
            Button {
                trackButtonAction(index)
            } label: {
                // FIXME highlight is broken when user have result more than one section
                Text(item.title)
                    .font(.title)
                    .foregroundStyle(index == selectedTrackIndex ? .yellow.opacity(0.8) : .white)
            }
            .buttonStyle(.borderless)
            .contextMenu {
                NavigationLink {
                    PlaylistsView(mode: .add, selectedTrackIndex: index, playlists: $playlists, filteredTracks: $filteredTracks, userService: userService)
                } label: {
                    Text(AppTexts.addToPlaylist)
                }
                Button(AppTexts.saveTrackPosition) {
                    userService.saveTrackPlaybackPosition(id: item.id, position: audioPlayer.currentTime)
                }
                Button(AppTexts.resetTrackPosition) {
                    userService.removeTrackPlaybackPosition(id: item.id)
                }
                Button(AppTexts.deleteTrack) {
                    selectedTrackForFileActions = item
                    showDeleteAlert = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var SeekBar: some View {
        if showSeekbar {
            SeekbarView(audioPlayer: audioPlayer, selectPreviousTrack: selectPreviousTrack, selectNextTrack: selectNextTrack)
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
            showSortOptions = true
        } label: {
            Label(AppTexts.playModeTitle, systemImage: AppIcons.sort)
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
    
    func playSelectedTrack() {
        let track = filteredTracks[selectedTrackIndex]
        let savedTrackPosition = userService.readTrackPlaybackPosition(id: track.id)
        audioPlayer.play(track: track, savedTrackPosition: savedTrackPosition)
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
        fileUtil.browse { url in
            addTracksFromGiven(folderURL: url)
            userService.saveFolderURL(url: url)
        }
    }
    
    private func addTracksFromGiven(folderURL: URL) {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: []) else {
            return
        }
        
        Task(priority: .high) {
            for url in urls.supportedUrls {
                await tracks.append(url.toTrack())
            }
            
            await MainActor.run {
                tracks = tracks.sort(.aToZ)
                filteredTracks = tracks
            }
            
            AppLogger.shared.info("Total Track Counts: \(filteredTracks.count)")
        }
    }
}

#Preview {
    HomeView()
}
