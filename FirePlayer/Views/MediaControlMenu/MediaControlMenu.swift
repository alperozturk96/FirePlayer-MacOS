//
//  MediaControlMenu.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 19.11.2023.
//

import SwiftUI

struct MediaControlMenu: View {
    @StateObject private var audioPlayerService = AudioPlayerService.shared
    
    var body: some View {
        HStack {
            ImageButtonWithText(title: "media_control_menu_previous".localized, icon: "arrowshape.backward.circle.fill") {
                publish(event: .previous)
            }
            ImageButtonWithText(title: audioPlayerService.toggleText.localized, icon: audioPlayerService.toggleIcon) {
                publish(event: .toggle)
            }
            ImageButtonWithText(title: "media_control_menu_next".localized, icon: "arrowshape.forward.circle.fill") {
                publish(event: .next)
            }
        }
    }
}

#Preview {
    MediaControlMenu()
}
