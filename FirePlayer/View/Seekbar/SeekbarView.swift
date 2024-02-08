//
//  SeekbarView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 16.11.2023.
//

import SwiftUI
import AVFoundation

struct SeekbarView: View {
    
    @ObservedObject var audioPlayer: AudioPlayer
    let selectPreviousTrack: () -> ()
    let selectNextTrack: () -> ()
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 15)
            
            if let currrentDurationRepresentation = audioPlayer.player.currrentDurationRepresentation {
                Text(currrentDurationRepresentation)
            }
            
            if let duration = audioPlayer.player.duration {
                Slider(value: Binding(
                    get: {
                        audioPlayer.currentTime
                    },
                    set: { seekedTime in
                        audioPlayer.seek(to: seekedTime)
                    }
                ), in: 0.0...duration)
            }
            
            if let durationRepresentation = audioPlayer.player.durationRepresentation {
                Text(durationRepresentation)
            }
            
            Spacer()
            
            ImageButton(icon: AppIcons.previous) {
                selectPreviousTrack()
            }
            .keyboardShortcut(.leftArrow, modifiers: [])
            
            ImageButton(icon: audioPlayer.toggleIcon) {
                audioPlayer.player.toggle()
            }
            .keyboardShortcut(.space, modifiers: [])
            
            ImageButton(icon: AppIcons.next) {
                selectNextTrack()
            }
            .keyboardShortcut(.rightArrow, modifiers: [])
            
            Spacer()
                .frame(width: 15)
        }
        .focusable()
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color(AppColors.Seekbar))
    }
}
