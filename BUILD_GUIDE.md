# Building iOS Apps on Windows with xtool

A complete step-by-step guide to building and signing iOS applications on Windows using WSL and xtool.

## Prerequisites

- Windows 10/11 with WSL2 enabled
- Ubuntu 24.04 in WSL
- Apple Developer Account (free or paid)
- Xcode.xip file (download from developer.apple.com)
- iPhone for testing

---

## Step 1: Install WSL2 and Ubuntu

```powershell
# In PowerShell (Admin)
wsl --install -d Ubuntu-24.04
```

---

## Step 2: Install Swift Toolchain in WSL

```bash
# Download Swift 6.2.3 for Ubuntu 24.04
cd ~
wget https://download.swift.org/swift-6.2.3-release/ubuntu2404/swift-6.2.3-RELEASE/swift-6.2.3-RELEASE-ubuntu24.04.tar.gz

# Extract
tar -xzf swift-6.2.3-RELEASE-ubuntu24.04.tar.gz

# Move to install location
mkdir -p ~/swift_install
mv swift-6.2.3-RELEASE-ubuntu24.04 ~/swift_install/
```

---

## Step 3: Install Required Dependencies

```bash
# Install build tools and libraries
sudo apt-get update
sudo apt-get install -y build-essential libncurses6 libimobiledevice-utils usbmuxd zip
```

---

## Step 4: Install xtool

```bash
# Download xtool AppImage
cd ~
wget https://github.com/nicklockwood/xtool/releases/latest/download/xtool-linux-x86_64.AppImage -O xtool.AppImage
chmod +x xtool.AppImage

# Extract AppImage (required for WSL)
./xtool.AppImage --appimage-extract
```

---

## Step 5: Create Wrapper Script

Create `fixed_xtool.sh` in your project directory:

```bash
#!/bin/bash

# Check and install libncurses6 if needed
if ! dpkg -s libncurses6 &> /dev/null; then
    echo "Installing libncurses6..."
    sudo apt-get install -y libncurses6
fi

# Set Swift path
export PATH="$HOME/swift_install/swift-6.2.3-RELEASE-ubuntu24.04/usr/bin:$PATH"

# Set TMPDIR to avoid permission issues
export TMPDIR="$HOME/tmp"
mkdir -p "$TMPDIR"

# Run xtool
~/squashfs-root/usr/bin/xtool "$@"
```

Make it executable:
```bash
chmod +x fixed_xtool.sh
```

---

## Step 6: Setup xtool with Xcode SDK

```bash
# Run setup (provide path to Xcode.xip when prompted)
./fixed_xtool.sh setup

# Authenticate with Apple ID
./fixed_xtool.sh auth
```

---

## Step 7: Create Project Structure

```
project/
├── Package.swift
├── xtool.yml
├── fixed_xtool.sh
└── iosapp/
    ├── iosappApp.swift
    ├── ContentView.swift
    ├── AudioPlayerViewModel.swift
    ├── Info.plist
    ├── audio/
    │   └── sleepsong.mp3
    └── Assets.xcassets/
        └── AppIcon.appiconset/
            ├── Contents.json
            └── icon-1024.png
```

---

## Step 8: Create Package.swift

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

---

## Step 9: Create xtool.yml

```yaml
version: 1
orgID: "YOUR_TEAM_ID"
displayName: "Your App Name"
infoPath: "iosapp/Info.plist"
```

---

## Step 10: Create Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIcons</key>
    <dict>
        <key>CFBundlePrimaryIcon</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>AppIcon60x60</string>
            </array>
        </dict>
    </dict>
    <key>CFBundleIcons~ipad</key>
    <dict>
        <key>CFBundlePrimaryIcon</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>AppIcon60x60</string>
                <string>AppIcon76x76</string>
            </array>
        </dict>
    </dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>Your App Name</string>
    <key>CFBundleExecutable</key>
    <string>iosapp</string>
    <key>CFBundleIdentifier</key>
    <string>com.yourname.appname</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Your App Name</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
    </array>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
</dict>
</plist>
```

---

## Step 11: Build the App

```bash
# Copy project to WSL home directory (avoids permission issues)
cp -r /mnt/c/your/project ~/iosapp_build

# Navigate to project
cd ~/iosapp_build

# Build
./fixed_xtool.sh dev
```

---

## Step 12: Add App Icons to Bundle

After build completes, copy icon files to app bundle:

```bash
cd ~/iosapp_build/xtool/iosapp.app

# Copy 1024x1024 icon to required sizes
cp /path/to/icon-1024.png AppIcon60x60@2x.png
cp /path/to/icon-1024.png AppIcon60x60@3x.png
cp /path/to/icon-1024.png AppIcon76x76@2x.png
```

---

## Step 13: Copy Info.plist with CFBundleIcons

```bash
# xtool regenerates Info.plist, so copy source with CFBundleIcons
cp /mnt/c/your/project/iosapp/Info.plist ~/iosapp_build/xtool/iosapp.app/
```

---

## Step 14: Create IPA File

```bash
# Navigate to output
cd /mnt/c/your/project

# Create Payload folder
mkdir -p Payload

# Copy app bundle
cp -r ~/iosapp_build/xtool/iosapp.app Payload/

# Create IPA
zip -r yourapp.ipa Payload

# Cleanup
rm -rf Payload
```

---

## Step 15: Install on Device

### Using Sideloadly (Recommended)
1. Download [Sideloadly](https://sideloadly.io/)
2. Connect iPhone via USB
3. Drag IPA into Sideloadly
4. Enter Apple ID, click Start
5. On iPhone: Settings → General → VPN & Device Management → Trust certificate
6. Enable Developer Mode: Settings → Privacy & Security → Developer Mode → ON

---

## Quick Build Script

Create `build.sh` for one-command builds:

```bash
#!/bin/bash
cd ~/iosapp_build
rm -rf .build xtool
./fixed_xtool.sh dev

# Add icons
cd ~/iosapp_build/xtool/iosapp.app
cp /mnt/c/iosapp/iosapp/Assets.xcassets/AppIcon.appiconset/icon-1024.png AppIcon60x60@2x.png
cp /mnt/c/iosapp/iosapp/Assets.xcassets/AppIcon.appiconset/icon-1024.png AppIcon60x60@3x.png
cp /mnt/c/iosapp/iosapp/Assets.xcassets/AppIcon.appiconset/icon-1024.png AppIcon76x76@2x.png

# Copy Info.plist with CFBundleIcons
cp /mnt/c/iosapp/iosapp/Info.plist ~/iosapp_build/xtool/iosapp.app/

# Create IPA
rm -rf /mnt/c/iosapp/iosapp.ipa /mnt/c/iosapp/Payload
mkdir -p /mnt/c/iosapp/Payload
cp -r ~/iosapp_build/xtool/iosapp.app /mnt/c/iosapp/Payload/
cd /mnt/c/iosapp
zip -r iosapp.ipa Payload
rm -rf Payload

echo "IPA created at /mnt/c/iosapp/iosapp.ipa"
```

---

## Troubleshooting

### Build fails with Swift concurrency errors
Use delegate wrapper pattern for AVAudioPlayerDelegate:
```swift
private class AudioPlayerDelegateWrapper: NSObject, AVAudioPlayerDelegate {
    private let onFinished: (Bool) -> Void
    // ...
}
```

### Audio doesn't play in background
- Ensure `UIBackgroundModes` with `audio` is in Info.plist
- Set `infoPath` in xtool.yml
- Use `.playback` category for AVAudioSession

### App icon not showing
- Add CFBundleIcons to Info.plist
- Copy source Info.plist to built app bundle (xtool regenerates it)
- Icon files must be named: AppIcon60x60@2x.png, AppIcon60x60@3x.png, AppIcon76x76@2x.png

### Bundle identifier error in Sideloadly
Replace Xcode variables like `$(PRODUCT_BUNDLE_IDENTIFIER)` with actual values in Info.plist
