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
    let playPreviousTrack: () -> ()
    let playNextTrack: () -> ()

    var body: some View {
        HStack {
            if let currrentDurationRepresentation = audioPlayerService.player.currrentDurationRepresentation {
                Text(currrentDurationRepresentation)
            }
            
            Slider(value: Binding(
                get: { audioPlayerService.currentTime },
                set: { newValue in
                    audioPlayerService.seek(to: newValue)
                }
            ), in: 0...audioPlayerService.totalTime, onEditingChanged: { editingChanged in
                if !editingChanged {
                    audioPlayerService.seek(to: audioPlayerService.currentTime)
                }
            })
            
            if let durationRepresentation = audioPlayerService.player.durationRepresentation {
                Text(durationRepresentation)
            }
            
            Spacer()
            
            ImageButton(icon: "arrowshape.backward.circle.fill") {
                playPreviousTrack()
            }
            
            ImageButton(icon: audioPlayerService.player.isPlaying ? "pause.circle.fill" : "play.circle.fill") {
                audioPlayerService.player.toggle()
            }
            
            ImageButton(icon: "arrowshape.forward.circle.fill") {
                playNextTrack()
            }
            
            Spacer()
                .frame(width: 15)
        }
        
        .focusable()
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.gray.opacity(0.3))
    }
}
