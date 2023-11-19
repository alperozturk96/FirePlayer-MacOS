//
//  ViewExtensions.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 19.11.2023.
//

import SwiftUI

extension View {
    func ImageButton(icon: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .frame(width: 35, height: 35)
        }
    }
    
    func ImageButtonWithText(title:String, icon: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                
                Image(systemName: icon)
                    .frame(width: 35, height: 35)
            }
        }
    }
}
