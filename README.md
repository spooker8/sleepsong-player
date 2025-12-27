# 🎵 Sleep Song Player

An iOS audio player app with background playback support, built entirely on Windows using Swift Package Manager and [xtool](https://xtool.sh).

## ✨ Features

- 🎵 **Audio Playback** - Play MP3 audio files with full playback controls
- 🔄 **Background Audio** - Music continues playing when the app is minimized or screen is locked
- 🎛️ **Lock Screen Controls** - Control playback from the iOS lock screen and Control Center
- ⏩ **Playback Controls** - Play, pause, stop, rewind (10s), fast-forward (10s)
- 📊 **Progress Bar** - Visual progress indicator with seek functionality
- 🎨 **Modern UI** - Beautiful gradient background with SwiftUI

## 📱 Screenshots

The app features a clean, modern interface with:
- Gradient purple/blue background
- Large play/pause button
- Rewind and fast-forward controls
- Progress slider with time display
- Stop button

## 🛠️ How It Was Built

This app was built **entirely on Windows** without Xcode, using:

### Technologies
- **Swift 6.2.3** - Latest Swift toolchain for Ubuntu
- **SwiftUI** - Modern declarative UI framework
- **AVFoundation** - Audio playback and session management
- **MediaPlayer** - Lock screen and Control Center integration
- **xtool** - Cross-platform iOS build tool

### Build Environment
- **Windows 11** with WSL2 (Ubuntu 24.04)
- **xtool** for iOS compilation and signing
- **Swift Package Manager** for dependency management
- **Xcode 26.2 SDK** - Extracted for iOS frameworks

### Key Implementation Details

#### Background Audio
Background audio playback requires two things:

1. **Info.plist Configuration**:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

2. **AVAudioSession Setup**:
```swift
let audioSession = AVAudioSession.sharedInstance()
try audioSession.setCategory(.playback, mode: .default, options: [])
try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
```

#### Swift 6 Concurrency
The app uses a delegate wrapper pattern to handle Swift 6's strict concurrency requirements:

```swift
private class AudioPlayerDelegateWrapper: NSObject, AVAudioPlayerDelegate {
    private let onFinished: (Bool) -> Void
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinished(flag)
    }
}
```

## 🚀 Building the App

### Prerequisites

1. **Windows with WSL2** (Ubuntu 24.04 recommended)
2. **Swift toolchain** for Linux
3. **xtool** installed in WSL
4. **Xcode.xip** for iOS SDK extraction
5. **Apple Developer Account** (free or paid)

### Setup Steps

1. **Install Swift in WSL**:
```bash
wget https://download.swift.org/swift-6.2.3-release/ubuntu2404/swift-6.2.3-RELEASE/swift-6.2.3-RELEASE-ubuntu24.04.tar.gz
tar -xzf swift-6.2.3-RELEASE-ubuntu24.04.tar.gz
export PATH="$HOME/swift-6.2.3-RELEASE-ubuntu24.04/usr/bin:$PATH"
```

2. **Install xtool**:
```bash
# Download xtool AppImage and extract
./xtool --appimage-extract
```

3. **Setup iOS SDK**:
```bash
./fixed_xtool.sh setup
# Provide path to Xcode.xip when prompted
```

4. **Build the App**:
```bash
./fixed_xtool.sh dev
```

### Configuration Files

**xtool.yml**:
```yaml
version: 1
orgID: "YOUR_TEAM_ID"
displayName: "Sleep Song Player"
infoPath: "iosapp/Info.plist"
```

**Package.swift**:
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iosapp",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "iosapp", targets: ["iosapp"])
    ],
    targets: [
        .target(
            name: "iosapp",
            dependencies: [],
            path: "iosapp",
            resources: [
                .process("audio"),
                .process("Assets.xcassets")
            ]
        )
    ]
)
```

## 📁 Project Structure

```
iosapp/
├── Package.swift           # Swift Package Manager config
├── xtool.yml              # xtool build configuration
├── fixed_xtool.sh         # WSL build wrapper script
├── xtool.bat              # Windows batch wrapper
├── README.md              # This file
└── iosapp/
    ├── iosappApp.swift    # App entry point
    ├── ContentView.swift  # Main UI
    ├── AudioPlayerViewModel.swift  # Audio logic
    ├── Info.plist         # iOS app configuration
    ├── audio/
    │   └── sleepsong.mp3  # Audio file
    └── Assets.xcassets/
        └── AppIcon.appiconset/
            ├── Contents.json
            └── icon-1024.png
```

## 📲 Installation

### Option 1: Sideloadly (Recommended)
1. Download [Sideloadly](https://sideloadly.io/)
2. Connect your iPhone via USB
3. Drag the `iosapp.ipa` into Sideloadly
4. Enter your Apple ID and click Start
5. On iPhone: Settings → General → VPN & Device Management → Trust the certificate
6. Enable Developer Mode: Settings → Privacy & Security → Developer Mode → ON

### Option 2: AltStore
1. Install [AltStore](https://altstore.io/)
2. Use AltStore to install the IPA

## 🔧 Troubleshooting

### Audio Doesn't Play in Background
- Ensure `UIBackgroundModes` with `audio` is in Info.plist
- Check that `infoPath` is set in xtool.yml
- Verify AVAudioSession is set to `.playback` category

### Build Fails with Swift Concurrency Errors
- Use the delegate wrapper pattern for AVAudioPlayerDelegate
- Mark view models with `@MainActor`

### Bundle Identifier Error in Sideloadly
- Replace Xcode variables like `$(PRODUCT_BUNDLE_IDENTIFIER)` with actual values in Info.plist

## 📄 License

MIT License - feel free to use and modify!

## 🙏 Acknowledgments

- [xtool](https://xtool.sh) - Making iOS development possible on Windows/Linux
- Apple's SwiftUI and AVFoundation frameworks
