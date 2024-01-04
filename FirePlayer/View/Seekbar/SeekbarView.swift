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
    
    @State private var isSeeking = false
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 15)
            
            if let currrentDurationRepresentation = audioPlayer.player.currrentDurationRepresentation {
                Text(currrentDurationRepresentation)
            }
            
            Slider(value: $audioPlayer.currentTime, in: 0...audioPlayer.totalTime, onEditingChanged: sliderEditingChanged)
                .onChange(of: audioPlayer.currentTime) {
                    if isSeeking {
                        audioPlayer.seek()
                    }
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
        .onChange(of: audioPlayer.isPlaying) {
            if audioPlayer.isTrackFinished {
                selectNextTrack()
            }
        }
        .focusable()
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color(AppColors.Seekbar))
    }
}

// MARK: - Private Methods
extension SeekbarView {
    private func sliderEditingChanged(_ editingStarted: Bool) {
        isSeeking = editingStarted
        if !editingStarted {
            audioPlayer.seek()
        }
    }
}
