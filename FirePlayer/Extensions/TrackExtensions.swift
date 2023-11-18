//
//  TrackExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 17.11.2023.
//

import Foundation

extension Array where Element == Track {
    func sortByTitleAZ() -> [Track] {
        return self.sorted { $0.title < $1.title }
    }

    func sortByTitleZA() -> [Track] {
        return self.sorted { $0.title > $1.title }
    }
    
    func getSelectedTrack(index: Int) -> URL {
        self[index].path
    }
}
