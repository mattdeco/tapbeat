# TapBeat

[![Release](https://img.shields.io/github/v/release/mattdeco/tapbeat)](https://github.com/mattdeco/tapbeat/releases/latest)

Ultra-light macOS BPM counter. Press spacebar (or click the window) to tap tempo; Esc or R to reset.

<img src="docs/screenshot.png" alt="TapBeat showing a tapped BPM on its LCD" width="326">

## Download

Grab the latest build from [Releases](https://github.com/mattdeco/tapbeat/releases/latest):

- **File:** `TapBeat-<version>-macos.zip` (universal: Apple Silicon + Intel)
- **Requires:** macOS 13 or later

1. Download and unzip the archive.
2. Drag `TapBeat.app` into `/Applications` (or open it wherever you like).

Builds are **not** Apple Developer ID–signed or notarized. The first time you open the app, macOS Gatekeeper may block it—that’s expected for unsigned downloads.

### If macOS blocks the app

1. In Finder, **Control-click** (or right-click) `TapBeat.app`.
2. Choose **Open**.
3. In the dialog, click **Open** again.

After that, double-click works normally.

If you don’t see the Open option, open **System Settings → Privacy & Security**, scroll to the message about TapBeat being blocked, and click **Open Anyway**.

## Build from source

### Debug

```bash
xcodebuild -project TapBeat.xcodeproj -scheme TapBeat -configuration Debug -derivedDataPath build
open build/Build/Products/Debug/TapBeat.app
```

### Release

```bash
xcodebuild -project TapBeat.xcodeproj -scheme TapBeat -configuration Release -derivedDataPath build
open build/Build/Products/Release/TapBeat.app
```

To install the Release build:

```bash
cp -R build/Build/Products/Release/TapBeat.app /Applications/
```

### Publish a release

Push a version tag; GitHub Actions builds the zip and attaches it to a Release:

```bash
git tag v1.0.0
git push origin v1.0.0
```
