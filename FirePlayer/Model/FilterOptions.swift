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
            "home_filter_by_title_section_title".localized
        case .artist:
            "home_filter_by_artist_section_title".localized
        case .album:
            "home_filter_by_album_section_title".localized
        }
    }
    
    var searchPrompt: String {
        return switch self {
        case .title:
            "home_search_in_title_prompt".localized
        case .artist:
            "home_search_in_artists_prompt".localized
        case .album:
            "home_search_in_albums_prompt".localized
        }
    }
    
    var icon: String {
        return switch self {
        case .title:
            "textformat.alt"
        case .artist:
            "person.fill"
        case .album:
            "rectangle.stack.fill"
        }
    }
}
