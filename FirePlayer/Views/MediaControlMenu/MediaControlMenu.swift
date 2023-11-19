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
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationCenterEvents.previous.rawValue), object: nil, userInfo: nil)
            }
            ImageButtonWithText(title: "Play | Pause", icon: "playpause.fill") {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationCenterEvents.playerToggle.rawValue), object: nil, userInfo: nil)
            }
            ImageButtonWithText(title: "Next", icon: "arrowshape.forward.circle.fill") {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationCenterEvents.next.rawValue), object: nil, userInfo: nil)
            }
        }
    }
}

#Preview {
    MediaControlMenu()
}
