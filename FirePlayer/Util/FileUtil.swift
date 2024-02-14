//
//  FolderAnalyzer.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 10.10.2023.
//

import Foundation
import AppKit

struct FileUtil {
    
    func browse(onComplete: @escaping (URL) -> ()) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        
        openPanel.begin { result in
            if result == .OK {
                guard let selectedPath = openPanel.url else {
                    return
                }
                
                onComplete(selectedPath)
            }
        }
    }
    
    
    func deleteFile(url: URL, onComplete: @escaping () -> ()) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
            AppLogger.shared.info("File deleted successfully")
            onComplete()
        } catch {
            AppLogger.shared.info("Error deleting file: \(error.localizedDescription)")
        }
    }
    
    @MainActor 
    func scanPreviouslySelectedFolder(_ audioPlayer: AudioPlayer, onComplete: @escaping () -> ()) {
        guard audioPlayer.tracks.isEmpty else { return }
        
        guard let url = audioPlayer.userService.readFolderURL() else {
            return
        }
        
        audioPlayer.addTracksFromGiven(folderURL: url) {
            onComplete()
        }
    }
    
    @MainActor 
    func scanFolder(_ audioPlayer: AudioPlayer, onComplete: @escaping () -> ()) {
        browse { url in
            audioPlayer.addTracksFromGiven(folderURL: url) {
               onComplete()
            }
            audioPlayer.userService.saveFolderURL(url: url)
        }
    }
}
