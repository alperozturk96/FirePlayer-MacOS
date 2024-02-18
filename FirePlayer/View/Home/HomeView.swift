//
//  HomeView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 2.10.2023.
//

import SwiftUI

struct HomeView: View {
    private let fileUtil = FileUtil()
    
    @StateObject var audioPlayer = AudioPlayer.shared
    
    @State private var selectedFilterOption: FilterOptions = .title
    @State private var playlists: [String: [Int]] = [:]
    @State private var selectedTrackForFileActions: Track?
    @State private var showSeekbar = false
    @State private var showSortOptions = false
    @State private var showDeleteAlert = false
    @State private var showLoadingIndicator = true
    @State private var searchText = ""
    @State private var sortOption: SortOptions = .aToZ
    
    var body: some View {
        NavigationView {
            List {
                TracksButton
                PlaylistsButton
            }
            .listStyle(SidebarListStyle())
            
            Group {
                if audioPlayer.filteredTracks.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ScrollViewReader { proxy in
                        List {
                            Section(header: Text(selectedFilterOption.header)) {
                                TrackList(proxy: proxy)
                            }
                        }
                        .onChange(of: audioPlayer.selectedTrackIndex) {
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
                audioPlayer.scanPreviouslySelectedFolder {
                    showLoadingIndicator = false
                }
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
                audioPlayer.filteredTracks = audioPlayer.filteredTracks.sort(sortOption)
            }
            .onChange(of: audioPlayer.selectedTrackIndex) {
                audioPlayer.playSelectedTrack()
            }
            .toolbar {
                ToolbarItem {
                    if showLoadingIndicator {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
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
                                audioPlayer.filteredTracks.remove(selectedTrackForFileActions)
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onDrop(of: ["public.file-url"], isTargeted: nil) { providers -> Bool in
                providers.handleDroppedFile(audioPlayer: audioPlayer) { droppedFileIndex in
                    trackButtonAction(droppedFileIndex)
                }
                return true
            }
        }
    }
}

// MARK: - ChildViews
extension HomeView {
    private func TrackList(proxy: ScrollViewProxy) -> some View {
        ForEach(Array(audioPlayer.filteredTracks.enumerated()), id: \.offset) { index, item in
            Button {
                trackButtonAction(index)
            } label: {
                // FIXME highlight is broken when user have result more than one section
                Text(item.title)
                    .font(.title)
                    .foregroundStyle(index == audioPlayer.selectedTrackIndex ? .yellow.opacity(0.8) : .white)
            }
            .buttonStyle(.borderless)
            .contextMenu {
                NavigationLink {
                    PlaylistsView(mode: .add, selectedTrackIndex: index, playlists: $playlists, filteredTracks: $audioPlayer.filteredTracks, userService: audioPlayer.userService)
                } label: {
                    Text(AppTexts.addToPlaylist)
                }
                Button(AppTexts.saveTrackPosition) {
                    audioPlayer.saveTrackPlaybackPosition(id: item.id)
                }
                Button(AppTexts.resetTrackPosition) {
                    audioPlayer.removeTrackPlaybackPosition(id: item.id)
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
            SeekbarView(audioPlayer)
        }
    }
}

// MARK: - Buttons
extension HomeView {
    private var PlayModeButton: some View {
        Button {
            audioPlayer.playMode = audioPlayer.playMode.next
        } label: {
            Label(AppTexts.playModeTitle, systemImage: audioPlayer.playMode.icon)
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
            PlaylistsView(mode: .select, selectedTrackIndex: nil, playlists: $playlists, filteredTracks: $audioPlayer.filteredTracks, userService: audioPlayer.userService)
        } label: {
            Label(AppTexts.playlists, systemImage: AppIcons.playlists)
        }
    }
    
    private var ScanFolderButton: some View {
        Button {
            audioPlayer.scanFolder(fileUtil) { showLoadingIndicator = false }
        } label: {
            Label(AppTexts.scan, systemImage: AppIcons.folder)
        }
    }
}

// MARK: - Private Methods
extension HomeView {
    private func trackButtonAction(_ index: Int) {
        audioPlayer.changeIndex(index)
        
        if !showSeekbar {
            showSeekbar = true
        }
    }
    
    private func scrollToSelectedTrack(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(audioPlayer.selectedTrackIndex, anchor: .center)
        }
    }
    
    private func resetFilteredTracks() {
        audioPlayer.filteredTracks = audioPlayer.tracks
        searchText = ""
    }
    
    private func readPreviouslySavedPlaylists() {
        playlists = audioPlayer.userService.readPlaylists()
    }
    
    private func search() {
        audioPlayer.search(selectedFilterOption, searchText: searchText)
    }
}

#Preview {
    HomeView()
}
