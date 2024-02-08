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
        } else if sortOption == .zToA {
            sorted { $0.title > $1.title }
        } else if sortOption == .newToOld {
            sorted { $0.dateModified ?? .now > $1.dateModified ?? .now }
        } else {
            // FIXME
            sorted { $0.dateModified ?? .now < $1.dateModified ?? .now }
        }
    }
    
    func filter(_ filterOption: FilterOptions, text: String) -> Self {
        return switch filterOption {
        case .title:
            filter { $0.title.normalize.localizedCaseInsensitiveContains(text.normalize) }
        case .artist:
            filter { $0.artist.normalize.localizedCaseInsensitiveContains(text.normalize) }
        case .album:
            filter { $0.album.normalize.localizedCaseInsensitiveContains(text.normalize) }
        }
    }
    
    var randomIndex: Int {
        Int.random(in: 0..<self.count)
    }
}
