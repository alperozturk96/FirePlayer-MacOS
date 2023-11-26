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
            ImageButtonWithText(title: AppTexts.previous, icon: AppIcons.previous) {
                publish(event: .previous)
            }
            ImageButtonWithText(title: audioPlayerService.toggleText.localized, icon: audioPlayerService.toggleIcon) {
                publish(event: .toggle)
            }
            ImageButtonWithText(title: AppTexts.next, icon: AppIcons.next) {
                publish(event: .next)
            }
        }
    }
}

#Preview {
    MediaControlMenu()
}
