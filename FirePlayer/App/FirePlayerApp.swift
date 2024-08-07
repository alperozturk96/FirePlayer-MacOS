//
//  FirePlayerApp.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 2.10.2023.
//

import SwiftUI

@main
struct FirePlayerApp: App {
    var body: some Scene {
        Window("FirePlayer", id: "FirePlayerId") {
            NavigationStack {
                HomeView()
            }
        }
        .modelContainer(for: [Playlist.self, Track.self])
        
        MenuBarExtra("MediaControlMenu", systemImage: "flame.circle.fill") {
            PlayerMenuBar()
        }
    }
}
