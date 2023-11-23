//
//  SeekbarView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 16.11.2023.
//

import SwiftUI
import AVFoundation

struct SeekbarView: View {
    
    @ObservedObject var audioPlayerService: AudioPlayerService
    let selectPreviousTrack: () -> ()
    let selectNextTrack: () -> ()
    
    @State private var isSeeking = false
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 15)
            
            if let currrentDurationRepresentation = audioPlayerService.player.currrentDurationRepresentation {
                Text(currrentDurationRepresentation)
            }
            
            Slider(value: $audioPlayerService.currentTime, in: 0...audioPlayerService.totalTime, onEditingChanged: sliderEditingChanged)
                .onChange(of: audioPlayerService.currentTime) {
                    if isSeeking {
                        audioPlayerService.seek()
                    }
                }
            
            if let durationRepresentation = audioPlayerService.player.durationRepresentation {
                Text(durationRepresentation)
            }
            
            Spacer()
            
            ImageButton(icon: "arrowshape.backward.circle.fill") {
                selectPreviousTrack()
            }
            
            ImageButton(icon: audioPlayerService.player.isPlaying ? "pause.circle.fill" : "play.circle.fill") {
                audioPlayerService.player.toggle()
            }
            
            ImageButton(icon: "arrowshape.forward.circle.fill") {
                selectNextTrack()
            }
            
            Spacer()
                .frame(width: 15)
        }
        .onChange(of: audioPlayerService.isPlaying) {
            if audioPlayerService.isTrackFinished {
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
            audioPlayerService.seek()
        }
    }
}
