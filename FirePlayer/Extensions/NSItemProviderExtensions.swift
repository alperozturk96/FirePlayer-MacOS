//
//  NSItemProviderExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 18.02.2024.
//

import Foundation

extension [NSItemProvider] {
    @MainActor
    func handleDroppedFile(audioPlayer: AudioPlayer, whenDroppedFileIsInTrackList: @escaping (Int) -> ()) {
        first?.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, error in
            guard let data = data, let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            
            if !data.isMusicFile(url: url) {
                return
            }
            
            Task {
                guard let droppedTrackIndex = await audioPlayer.filteredTracks.getTrackIndex(url: url) else {
                    return
                }
                
                await MainActor.run {
                    whenDroppedFileIsInTrackList(droppedTrackIndex)
                }
            }
        }
    }
}
