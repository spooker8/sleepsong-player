import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Title
                VStack(spacing: 10) {
                    Image(systemName: "music.note")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    Text("Audio Player")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Now Playing")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                // Progress bar and time display
                VStack(spacing: 10) {
                    // Progress slider
                    Slider(
                        value: Binding(
                            get: { audioPlayerViewModel.currentTime },
                            set: { newValue in
                                let percentage = newValue / (audioPlayerViewModel.duration > 0 ? audioPlayerViewModel.duration : 1)
                                audioPlayerViewModel.seek(to: percentage)
                            }
                        ),
                        in: 0...max(audioPlayerViewModel.duration, 1)
                    )
                    .tint(.white)

                    // Time display
                    HStack {
                        Text(audioPlayerViewModel.formatCurrentTime())
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 50, alignment: .leading)

                        Spacer()

                        Text(audioPlayerViewModel.formatDuration())
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 50, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                // Playback controls
                HStack(spacing: 40) {
                    // Rewind button
                    Button(action: {
                        audioPlayerViewModel.rewind()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 60, height: 60)

                            Image(systemName: "backward.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }

                    // Play/Pause button
                    Button(action: {
                        if audioPlayerViewModel.isPlaying {
                            audioPlayerViewModel.pause()
                        } else {
                            audioPlayerViewModel.play()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 10)

                            Image(systemName: audioPlayerViewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.blue)
                        }
                    }

                    // Fast-forward button
                    Button(action: {
                        audioPlayerViewModel.fastForward()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 60, height: 60)

                            Image(systemName: "forward.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Stop button
                Button(action: {
                    audioPlayerViewModel.stop()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 18))
                        Text("Stop")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(25)
                }

                Spacer()

                // Info text
                Text("Swipe up from bottom or use lock screen for controls")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding()
        }
        .statusBar(hidden: false)
    }
}
