//
//  HomeView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 2.10.2023.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    private let fileUtil = FileUtil()
    
    @Environment(\.modelContext) private var modelContext
    
    @StateObject var audioPlayer = AudioPlayer.shared
    
    @Query
    private var playlists: [Playlist]
    
    @State var selectedTrackForFileActions: Track?
    @State var showSeekbar = false
    @State var showDeleteAlert = false
    @State var showLoadingIndicator = true
    @State var showAddToPlaylistSheet = false
    
    @State private var selectedFilterOption: FilterOptions = .title
    @State private var showSortOptions = false
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
                DeleteAlertDialog {
                    if let selectedTrackForFileActions {
                        fileUtil.deleteFile(url: selectedTrackForFileActions.path) {
                            audioPlayer.filteredTracks.remove(selectedTrackForFileActions)
                        }
                    }
                }
            }
            .onOpenURL { url in
                guard let openURLIndex = audioPlayer.filteredTracks.getTrackIndex(url: url) else {
                    return
                }
                
                trackButtonAction(openURLIndex)
            }
            .onDrop(of: ["public.file-url"], isTargeted: nil) { providers -> Bool in
                providers.handleDroppedFile(audioPlayer: audioPlayer) { droppedFileIndex in
                    trackButtonAction(droppedFileIndex)
                }
                return true
            }
            .sheet(isPresented: $showAddToPlaylistSheet) {
                List {
                    ForEach(playlists) { playlist in
                        Button(playlist.name) {
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ChildViews
extension HomeView {
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
            PlaylistsView()
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
    private func scrollToSelectedTrack(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(audioPlayer.selectedTrackIndex, anchor: .center)
        }
    }
    
    private func resetFilteredTracks() {
        audioPlayer.filteredTracks = audioPlayer.tracks
        searchText = ""
    }
    
    private func search() {
        audioPlayer.search(selectedFilterOption, searchText: searchText)
    }
}

#Preview {
    HomeView()
}
