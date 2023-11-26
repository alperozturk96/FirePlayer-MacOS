//
//  TrackExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 17.11.2023.
//

import Foundation

extension [Track] {
    func sort(_ sortOption: SortOptions) -> Self {
        return if sortOption == .aToZ {
            sorted { $0.title < $1.title }
        } else {
            sorted { $0.title > $1.title }
        }
    }
    
    func filter(_ filterOption: FilterOptions, text: String) -> Self {
        return switch filterOption {
        case .title:
            filter { $0.title.localizedCaseInsensitiveContains(text) }
        case .artist:
            filter { $0.artist.localizedCaseInsensitiveContains(text) }
        case .album:
            filter { $0.album.localizedCaseInsensitiveContains(text) }
        }
    }

    var randomIndex: Int {
        Int.random(in: 0..<self.count)
    }
}
