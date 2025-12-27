import SwiftUI
import AVFoundation
import MediaPlayer

@MainActor
class AudioPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackRate: Float = 1.0

    private var audioPlayer: AVAudioPlayer?
    private var updateTimer: Timer?
    private let rewindSeconds: TimeInterval = 10
    private let fastForwardSeconds: TimeInterval = 10
    
    // Delegate wrapper to handle callbacks
    private var delegateWrapper: AudioPlayerDelegateWrapper?

    init() {
        setupAudioSession()
        setupRemoteControl()
        setupInterruptionHandling()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio session configured for background playback")
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Interruption Handling
    private func setupInterruptionHandling() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleInterruption(notification: notification)
            }
        }
    }
    
    private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Interruption began, pause the audio
            print("Audio interruption began")
            pause()
        case .ended:
            // Interruption ended, check if we should resume
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    print("Audio interruption ended, resuming playback")
                    play()
                }
            }
        @unknown default:
            break
        }
    }

    // MARK: - Load Audio
    func loadAudio() {
        guard let url = Bundle.module.url(forResource: "sleepsong", withExtension: "mp3") else {
            print("Could not find audio file")
            return
        }

        do {
            // Ensure audio session is active before playing
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            // Create delegate wrapper
            delegateWrapper = AudioPlayerDelegateWrapper { [weak self] success in
                Task { @MainActor in
                    self?.handlePlaybackFinished(success: success)
                }
            } onError: { error in
                print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
            }
            
            audioPlayer?.delegate = delegateWrapper
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
            print("Audio loaded successfully. Duration: \(duration) seconds")

            // Auto-play on load
            play()
        } catch {
            print("Failed to load audio: \(error.localizedDescription)")
        }
    }
    
    private func handlePlaybackFinished(success: Bool) {
        isPlaying = false
        stopTimer()
        updateNowPlayingInfo()
        print("Playback finished. Success: \(success)")
    }

    // MARK: - Playback Controls
    func play() {
        guard let player = audioPlayer else { return }

        if player.play() {
            isPlaying = true
            startTimer()
            updateNowPlayingInfo()
            print("Playback started")
        } else {
            print("Failed to start playback")
        }
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
        updateNowPlayingInfo()
        print("Playback paused")
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        currentTime = 0
        isPlaying = false
        stopTimer()
        updateNowPlayingInfo()
        print("Playback stopped")
    }

    func rewind() {
        guard let player = audioPlayer else { return }

        let newTime = max(0, player.currentTime - rewindSeconds)
        player.currentTime = newTime
        currentTime = newTime
        updateNowPlayingInfo()
        print("Rewound to \(formatTime(newTime))")
    }

    func fastForward() {
        guard let player = audioPlayer else { return }

        let newTime = min(duration, player.currentTime + fastForwardSeconds)
        player.currentTime = newTime
        currentTime = newTime
        updateNowPlayingInfo()
        print("Fast-forwarded to \(formatTime(newTime))")
    }

    func seek(to percentage: Double) {
        guard let player = audioPlayer else { return }

        let newTime = duration * percentage
        player.currentTime = newTime
        currentTime = newTime
        updateNowPlayingInfo()
    }

    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgress()
            }
        }
    }

    private func stopTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func updateProgress() {
        guard let player = audioPlayer else { return }

        currentTime = player.currentTime
        updateNowPlayingInfo()
    }

    // MARK: - Now Playing Info
    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Sleep Song"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "iOS App"
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    // MARK: - Remote Control
    private func setupRemoteControl() {
        let commandCenter = MPRemoteCommandCenter.shared()

        // Play command
        commandCenter.playCommand.addTarget { [weak self] event in
            Task { @MainActor in
                self?.play()
            }
            return .success
        }

        // Pause command
        commandCenter.pauseCommand.addTarget { [weak self] event in
            Task { @MainActor in
                self?.pause()
            }
            return .success
        }

        // Stop command
        commandCenter.stopCommand.addTarget { [weak self] event in
            Task { @MainActor in
                self?.stop()
            }
            return .success
        }

        // Skip back command
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            Task { @MainActor in
                self?.rewind()
            }
            return .success
        }
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: rewindSeconds)]

        // Skip forward command
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            Task { @MainActor in
                self?.fastForward()
            }
            return .success
        }
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: fastForwardSeconds)]

        // Change playback position command
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            Task { @MainActor in
                let percentage = event.positionTime / (self?.duration ?? 1.0)
                self?.seek(to: percentage)
            }
            return .success
        }
    }

    // MARK: - Helper Methods
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func formatCurrentTime() -> String {
        formatTime(currentTime)
    }

    func formatDuration() -> String {
        formatTime(duration)
    }
}

// MARK: - Delegate Wrapper
private class AudioPlayerDelegateWrapper: NSObject, AVAudioPlayerDelegate {
    private let onFinished: (Bool) -> Void
    private let onError: (Error?) -> Void
    
    init(onFinished: @escaping (Bool) -> Void, onError: @escaping (Error?) -> Void) {
        self.onFinished = onFinished
        self.onError = onError
        super.init()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinished(flag)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        onError(error)
    }
}
