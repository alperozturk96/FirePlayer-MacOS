//
//  FolderAnalyzer.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 10.10.2023.
//

import Foundation
import AppKit

struct FolderAnalyzer {
    
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

}
