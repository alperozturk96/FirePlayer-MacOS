//
//  PlayerMenuBar.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 19.11.2023.
//

import SwiftUI

struct PlayerMenuBar: View {
    @StateObject private var audioPlayer = AudioPlayer.shared
    
    var body: some View {
        HStack {
            ImageButtonWithText(title: AppTexts.quit, icon: AppIcons.quit) {
                NSApplication.shared.terminate(self)
            }
            ImageButtonWithText(title: AppTexts.previous, icon: AppIcons.previous) {
                publish(event: .previous)
            }
            ImageButtonWithText(title: audioPlayer.toggleText.localized, icon: audioPlayer.toggleIcon) {
                publish(event: .toggle)
            }
            ImageButtonWithText(title: AppTexts.next, icon: AppIcons.next) {
                publish(event: .next)
            }
        }
    }
}

#Preview {
    PlayerMenuBar()
}
