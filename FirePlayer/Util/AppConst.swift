//
//  AppConst.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 26.11.2023.
//

import Foundation

enum AppIcons {
    static let previous = "arrowshape.backward.circle.fill"
    static let pause = "pause.circle.fill"
    static let play = "play.circle.fill"
    static let sort = "line.3.horizontal.decrease.circle.fill"
    static let next = "arrowshape.forward.circle.fill"
    static let tracks = "music.quarternote.3"
    static let playlists = "star.fill"
    static let folder = "folder.fill.badge.plus"
    static let star = "star"
    static let addPlaylist = "doc.fill.badge.plus"
    static let shuffle = "shuffle.circle.fill"
    static let sequential = "arrow.forward.to.line.circle.fill"
    static let loop = "point.forward.to.point.capsulepath.fill"
    static let title = "textformat.alt"
    static let artist = "person.fill"
    static let album = "rectangle.stack.fill"
    static let letterA = "a.circle.fill"
    static let letterZ = "z.circle.fill"
    static let newToOld = "arrow.down"
    static let oldToNew = "arrow.up"
}

enum AppTexts {
    static let ok = "common_ok".localized
    static let cancel = "common_cancel".localized

    static let previous = "media_control_menu_previous".localized
    static let pause = "media_control_menu_pause".localized
    static let play = "media_control_menu_play".localized
    static let next = "media_control_menu_next".localized
    
    static let sortByTitle = "home_sort_confirmation_dialog_by_title".localized
    static let sortByDate = "home_sort_confirmation_dialog_by_date".localized

    static let homeNavBarTitle = "home_navigation_bar_title".localized
    static let homeTrackSwipeTitle = "home_list_swipe_action_title".localized
    static let playModeTitle = "home_toolbar_play_mode_title".localized
    static let sortOptionsTitle = "home_toolbar_sort_options_title".localized
    static let filterOptionTitle = "home_toolbar_filter_option_title".localized
    static let tracks = "home_sidebar_tracks_title".localized
    static let playlists = "home_sidebar_playlists_title".localized
    static let scan = "home_toolbar_scan_title".localized
    
    static let playlistUnavailable = "playlists_content_unavailable_title".localized
    static let playlistContentUnavailable = "playlists_content_unavailable_text".localized
    static let playlistTrackSwipeTitle = "playlist_item_swipe_action_title".localized
    static let addPlaylistTitle = "home_playlist_confirmation_dialog_title".localized
    static let addPlaylistButton = "playlist_toolbar_add_playlist_title".localized
    static let addPlaylistPlaceholder = "playlist_add_playlist_placeholder".localized
    
    static let filterByTitle = "home_filter_by_title_section_title".localized
    static let filterByArtist = "home_filter_by_artist_section_title".localized
    static let filterByAlbum = "home_filter_by_album_section_title".localized
    static let filterByTitleSearchPrompt = "home_search_in_title_prompt".localized
    static let filterByArtistSearchPrompt = "home_search_in_artists_prompt".localized
    static let filterByAlbumSearchPrompt = "home_search_in_albums_prompt".localized
    
}

enum AppColors {
    static let Seekbar = "SeekbarColor"
}
