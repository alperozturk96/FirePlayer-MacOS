//
//  SeekbarView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 16.11.2023.
//

import SwiftUI

struct SeekbarView: View {
    
    @State private var isPlaying = false
    
    var body: some View {
        HStack {
            
            // TODO add seekbar progress here
           
            Spacer()
            
            ImageButton(icon: "arrowshape.backward.circle.fill") {
                
            }
            
            ImageButton(icon: isPlaying ? "pause.circle.fill" : "play.circle.fill") {
                
            }
            
            ImageButton(icon: "arrowshape.forward.circle.fill") {
                
            }
            
            Spacer()
                .frame(width: 15)
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.gray.opacity(0.3))
    }
}

extension SeekbarView {
    private func ImageButton(icon: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .frame(width: 35, height: 35)
        }
    }
}

#Preview {
    SeekbarView()
}
