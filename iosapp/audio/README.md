# Audio Files

This directory should contain your MP3 audio file.

## How to add your MP3 file:

1. Open Xcode and navigate to your project
2. In the Project Navigator, right-click on the `audio` folder
3. Select "Add Files to [Your Project Name]..."
4. Select your MP3 file
5. Make sure "Copy items if needed" is checked
6. Ensure your app target is selected
7. Click "Add"

**Important:** The MP3 file must be named `placeholder.mp3` for the app to find it automatically.

If you want to use a different filename, update the `loadAudio()` method in `AudioPlayerViewModel.swift`:

```swift
// Change this line:
guard let url = Bundle.main.url(forResource: "placeholder", withExtension: "mp3") else {

// To your filename:
guard let url = Bundle.main.url(forResource: "your-filename", withExtension: "mp3") else {
```

## Supported Audio Formats

The app uses `AVAudioPlayer` which supports:
- MP3
- AAC
- ALAC
- WAV
- AIFF
- HE-AAC
- iLBC
- IMA4
- Linear PCM
- µ-law and a-law
