//
//  MediaControlMenu.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 19.11.2023.
//

import SwiftUI

struct MediaControlMenu: View {
    var body: some View {
        HStack {
            ImageButtonWithText(title: "Previous", icon: "arrowshape.backward.circle.fill") {
                publish(event: .previous)
            }
            ImageButtonWithText(title: "Play | Pause", icon: "playpause.fill") {
                publish(event: .playerToggle)
            }
            ImageButtonWithText(title: "Next", icon: "arrowshape.forward.circle.fill") {
                publish(event: .next)
            }
        }
    }
}

#Preview {
    MediaControlMenu()
}
