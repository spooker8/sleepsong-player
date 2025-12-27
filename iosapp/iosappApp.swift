import SwiftUI
import AVFoundation

@main
struct iosappApp: App {
    @StateObject private var audioPlayerViewModel = AudioPlayerViewModel()

    init() {
        setupAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioPlayerViewModel)
                .onAppear {
                    audioPlayerViewModel.loadAudio()
                }
        }
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: []
            )
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio session configured successfully for background playback")
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
}
