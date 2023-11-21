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
    @Binding var playMode: PlayMode
    @Binding var selectedTrackIndex: Int
    @Binding var filteredTracks: [Track]
    
    @State private var playerItemObserver: Any?
    @State private var prevTrackIndexesStack: [Int] = []
    
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
        .onAppear {
            play()
            addPlayerObserver()
            addMenuBarObservers()
        }
        .onDisappear {
            removeObservers()
        }
        .focusable()
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.gray.opacity(0.3))
    }
}

// MARK: - Private Methods
extension SeekbarView {
    private func addMenuBarObservers() {
        receive(event: .previous) {
            playPreviousTrack()
        }
        
        receive(event: .play) {
            play()
        }
        
        receive(event: .playerToggle) {
            audioPlayerService.player.toggle()
        }
        
        receive(event: .next) {
            playNextTrack()
        }
    }
    
    private func playPreviousTrack() {
        if let prevIndex = getPrevSelectedTrackIndex() {
            selectedTrackIndex = prevIndex
        }
        
        play()
    }
    
    private func playNextTrack() {
        if playMode == .shuffle {
            selectedTrackIndex = filteredTracks.randomIndex
        } else {
            if selectedTrackIndex < filteredTracks.count {
                selectedTrackIndex += 1
            } else {
                selectedTrackIndex = 0
            }
        }
        
        prevTrackIndexesStack.append(selectedTrackIndex)
        play()
    }
    
    private func addPlayerObserver() {
        playerItemObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: audioPlayerService.player.currentItem,
            queue: nil) { _ in
                prevTrackIndexesStack.append(selectedTrackIndex)
                playNextTrack()
            }
    }
    
    private func getPrevSelectedTrackIndex() -> Int? {
        return prevTrackIndexesStack.popLast()
    }
    
    private func removeObservers() {
        if let observer = playerItemObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func play() {
        audioPlayerService.play(url: filteredTracks[selectedTrackIndex].path)
    }
    
    // let url = filteredTracks.getSelectedTrack(index: selectedTrackIndex)
}
