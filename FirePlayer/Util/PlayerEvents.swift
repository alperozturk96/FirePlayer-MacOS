//
//  PlayerEvents.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 19.11.2023.
//

import Foundation

enum PlayerEvents: String {
    case previous, toggle, next
}

func publish(event: PlayerEvents) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: event.rawValue), object: nil, userInfo: nil)
}

func receive(event: PlayerEvents, onReceive: @escaping () -> ()) {
    NotificationCenter.default.addObserver(forName: Notification.Name(event.rawValue), object: nil, queue: nil) { _ in
        onReceive()
    }
}
