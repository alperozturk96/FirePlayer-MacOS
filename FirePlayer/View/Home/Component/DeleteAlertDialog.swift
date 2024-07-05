//
//  DeleteAlertDialog.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 05.07.24.
//

import SwiftUI

extension HomeView {
    func DeleteAlertDialog(onClick: @escaping () -> ()) -> Alert {
        return Alert(
            title: Text(AppTexts.deleteAlertTitle),
            message: Text(AppTexts.deleteAlertDescription),
            primaryButton: .destructive(Text(AppTexts.ok)) {
                onClick()
            },
            secondaryButton: .cancel()
        )
    }
}
