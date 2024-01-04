//
//  Seekbar.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 10.10.2023.
//

import SwiftUI
import AVFoundation

struct Seekbar: View {
    @ObservedObject var audioPlayer: AudioPlayer
    
    @State private var isPlaying: Bool = false
    @State private var currentTime: TimeInterval = 0
    
    var body: some View {
        VStack(spacing: 0) {
           
            Slider(value: $currentTime, in: 0...TimeInterval(audioPlayer.currentTime), step: 1.0) { (changed) in
                if !changed {
                    let targetTime = CMTime(seconds: currentTime, preferredTimescale: 1)
                    //audioPlayer.player?.seek(to: targetTime)
                }
            }
            
            Spacer()
                .frame(height: 5)
            
            HStack {
                Text("\(formatTime(currentTime))")
                Spacer()
                Text("\(formatTime(audioPlayer.currentTime))")
            }
            
            Button(action: {
                if isPlaying {
                    player?.pause()
                } else {
                    player?.play()
                }
                
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            
            Spacer()
        }
        .background(Color.gray)
        .frame(height: 70)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
