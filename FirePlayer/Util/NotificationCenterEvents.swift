//
//  NotificationCenterEvents.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 19.11.2023.
//

import Foundation

enum NotificationCenterEvents: String {
    case previous, playerToggle, next
}

func publish(event: NotificationCenterEvents) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: event.rawValue), object: nil, userInfo: nil)
}

func receive(event: NotificationCenterEvents, onReceive: @escaping () -> ()) {
    NotificationCenter.default.addObserver(forName: Notification.Name(event.rawValue), object: nil, queue: nil) { _ in
        onReceive()
    }
}
