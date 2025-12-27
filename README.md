# iOS Audio Player App

A simple iOS audio player app built with SwiftUI and Swift Package Manager, designed to be compiled using xtool on Windows.

## Features

- Play MP3 audio files with auto-play on launch
- Standard playback controls: Play, Pause, Stop, Rewind (10s), Fast Forward (10s)
- Progress bar with seek functionality
- Time display (current position / total duration)
- Background playback support
- Lock screen and Control Center integration

## Project Structure

```
c:/iosapp/
├── Package.swift                    # SPM package manifest
├── Sources/
│   └── iosapp/
│       ├── iosappApp.swift           # App entry point
│       ├── ContentView.swift         # Main SwiftUI view
│       └── AudioPlayerViewModel.swift # Audio playback logic
├── Resources/
│   ├── Info.plist                    # App configuration
│   └── audio/
│       └── sleepsong.mp3            # Audio file
└── README.md                        # This file
```

## Requirements

- Windows 10/11 with WSL2 (Windows Subsystem for Linux)
- xtool installed (see https://github.com/xtool-org/xtool)
- Xcode SDK (download from https://developer.apple.com/download/all/)
- iPhone with iOS 17.0 or later
- USB cable for device connection

## Building with xtool

### Prerequisites

1. **Install Xcode SDK** (one-time setup):
   - Download Xcode.xip from https://developer.apple.com/download/all/
   - Install the SDK:
     ```bash
     xtool sdk install path/to/Xcode.xip
     ```

2. **Authenticate with Apple** (if not already done):
   ```bash
   xtool auth
   ```

3. Ensure xtool is properly installed and accessible via WSL:
   ```bash
   xtool --version
   ```

4. Connect your iPhone to your computer via USB and trust the computer on your device.

### Build the App

From the project root directory (`c:/iosapp`):

```bash
xtool dev
```

This will compile the Swift package and create the iOS app bundle.

**Note:** If you get an error about Swift not being found, ensure you've installed the Xcode SDK using `xtool sdk install <path>`.

### Deploy to iPhone

```bash
xtool install iosapp.ipa
```

This will install the app on your connected iPhone.

**Note:** First build the app using `xtool dev` to generate the `.ipa` file.

### Clean Build

Remove build artifacts:
```bash
# Remove .build directory
Remove-Item -Recurse -Force .build

# Or on Linux/WSL
rm -rf .build
```

### Other Useful Commands

```bash
# List connected devices
xtool devices

# Launch installed app
xtool launch com.example.iosapp

# Uninstall app
xtool uninstall com.example.iosapp
```

## Audio File

The app is configured to play `sleepsong.mp3` located in `Resources/audio/`. To use a different audio file:

1. Place your MP3 file in `Resources/audio/`
2. Update the filename in `Sources/iosapp/AudioPlayerViewModel.swift`:
   ```swift
   guard let url = Bundle.module.url(forResource: "audio/your-filename", withExtension: "mp3")
   ```

## Troubleshooting

### Build Errors

**Error: "Could not find audio file"**
- Ensure `sleepsong.mp3` exists in `Resources/audio/`
- Check that the filename matches exactly (case-sensitive)

**Error: "Could not find executable 'swift' in PATH"**
- Install Xcode SDK using: `xtool sdk install path/to/Xcode.xip`
- Download Xcode from https://developer.apple.com/download/all/

**Error: "Package.swift not found"**
- Ensure you're in the project root directory (`c:/iosapp`)

**Error: "xtool not found"**
- Ensure xtool is installed and accessible via WSL
- Try running `wsl xtool --version` to verify

### Deployment Issues

**Error: "No device found"**
- Ensure your iPhone is connected via USB
- Ensure you've trusted the computer on your iPhone (unlock device and tap "Trust")
- Try disconnecting and reconnecting the USB cable

**Error: "Installation failed"**
- Ensure your iPhone has enough storage space
- Try restarting your iPhone and computer

### Background Audio Not Working

- Ensure `UIBackgroundModes` is set to `audio` in `Resources/Info.plist`
- Check that the app has permission to play audio in background
- Test on a physical device (background audio may not work in simulator)

## Development

### Modifying the UI

The main UI is defined in `Sources/iosapp/ContentView.swift`. This file contains the SwiftUI view with:
- Gradient background
- Music note icon and title
- Progress slider
- Time display
- Playback control buttons

### Modifying Audio Logic

Audio playback logic is in `Sources/iosapp/AudioPlayerViewModel.swift`. Key components:
- `AVAudioPlayer` for audio playback
- `MPNowPlayingInfoCenter` for lock screen info
- `MPRemoteCommandCenter` for remote controls

### Adding Dependencies

To add Swift Package dependencies, update `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/example/package", from: "1.0.0")
]
```

And add to the target dependencies:
```swift
targets: [
    .executableTarget(
        name: "iosapp",
        dependencies: [
            .product(name: "PackageName", package: "PackageName")
        ],
        ...
    )
]
```

## License

This project is provided as-is for educational and personal use.

## Credits

- Built with SwiftUI
- Uses AVFoundation for audio playback
- Uses MediaPlayer for lock screen controls
- Compiled with xtool (https://github.com/xtool-org/xtool)
