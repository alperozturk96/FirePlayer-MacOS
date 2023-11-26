//
//  FilterOptions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 19.11.2023.
//

import Foundation

enum FilterOptions {
    case title, artist, album
    
    var next: Self {
        (self == .title) ? .artist : (self == .artist) ? .album : .title
    }
    
    var header: String {
        return switch self {
        case .title:
            AppTexts.filterByTitle
        case .artist:
            AppTexts.filterByArtist
        case .album:
            AppTexts.filterByAlbum
        }
    }
    
    var searchPrompt: String {
        return switch self {
        case .title:
            AppTexts.filterByTitleSearchPrompt
        case .artist:
            AppTexts.filterByArtistSearchPrompt
        case .album:
            AppTexts.filterByAlbumSearchPrompt
        }
    }
    
    var icon: String {
        return switch self {
        case .title:
            AppIcons.title
        case .artist:
            AppIcons.artist
        case .album:
            AppIcons.album
        }
    }
}
