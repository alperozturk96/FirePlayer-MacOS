//
//  SeekbarView.swift
//  FirePlayer
//
//  Created by Alper Ozturk on 16.11.2023.
//

import SwiftUI
import AVFoundation

struct SeekbarView: View {
    
    @Binding var selectedTrackIndex: Int?
    var tracks: [Track]
    
    @State private var playerItemObserver: Any?
    @State private var prevTrackIndexesStack: [Int] = []
    @State private var player = AVPlayer()
    @State private var currentTime: Double = 0
    @State private var totalTime: Double = 0
    
    var body: some View {
        HStack {
            Slider(value: Binding(
                get: { currentTime },
                set: { newValue in
                    seek(to: newValue)
                }
            ), in: 0...totalTime, onEditingChanged: { editingChanged in
                if !editingChanged {
                    seek(to: currentTime)
                }
            })
            
            Spacer()
            
            ImageButton(icon: "arrowshape.backward.circle.fill") {
                if let prevIndex = getPrevSelectedTrackIndex() {
                    selectedTrackIndex = prevIndex
                }
            }
            
            ImageButton(icon: player.isPlaying ? "pause.circle.fill" : "play.circle.fill") {
                player.toggle()
            }
            
            ImageButton(icon: "arrowshape.forward.circle.fill") {
                selectedTrackIndex = tracks.randomIndex
            }
            
            Spacer()
                .frame(width: 15)
        }
        .onAppear {
            play()
            addPlayerObserver()
        }
        .onDisappear {
            removeObservers()
        }
        .focusable()
        .onChange(of: selectedTrackIndex) {
            play()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.gray.opacity(0.3))
    }
}

// MARK: - Private Methods
extension SeekbarView {
    private func addPlayerObserver() {
        playerItemObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: nil) { _ in
                prevTrackIndexesStack.append(selectedTrackIndex ?? 0)
                selectedTrackIndex = tracks.randomIndex
            }
    }
    
    private func getPrevSelectedTrackIndex() -> Int? {
        return prevTrackIndexesStack.popLast()
    }
    
    private func removeObservers() {
        if let observer = playerItemObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func play() {
        Task {
            guard let selectedTrackIndex else { return }
            prevTrackIndexesStack.append(selectedTrackIndex)
            let url = tracks.getSelectedTrack(index: selectedTrackIndex)
            
            print("Path: ", url)
            
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.volume = 1
            player.play()
            
            await updateDuration()
            updateCurrentTime()
        }
    }
    
    private func updateDuration() async {
        guard let duration = try? await player.currentItem?.asset.load(.duration) else { return }
        currentTime = 0
        totalTime = CMTimeGetSeconds(duration)
    }
    
    private func updateCurrentTime() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsed in
            currentTime = CMTimeGetSeconds(player.currentTime())
        })
    }
    
    private func seek(to time: Double) {
        let timeCM = CMTime(seconds: time, preferredTimescale: 1)
        player.seek(to: timeCM)
    }
}

// MARK: - ChildViews
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
