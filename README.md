# VRMVTube

A cross-platform VTubing application using VRM avatars, built with Godot Engine.

![License: CC0-1.0](https://img.shields.io/badge/License-CC0_1.0-lightgrey.svg)
![Godot 4.3](https://img.shields.io/badge/Godot-4.3-blue.svg)

## Overview

VRMVTube is a VTubing application similar to [VRigUnity](https://github.com/Kariaro/VRigUnity), designed to provide real-time avatar animation using VRM models. This project is built with Godot Engine and supports multiple platforms.

**Key Features:**
- VRM model support (VRM 0.x and 1.0)
- Cross-platform support: Windows, macOS, Linux, Android, and Web
- **Real face tracking with MediaPipe (optional)**
- **Simulated tracking (built-in fallback)**
- **Real-time face rigging with VRM blend shapes**
- Interactive camera controls (drag, pan, zoom)
- Virtual camera output (Windows and Linux only)
- Real-time avatar rendering with MToon shader

## Face Tracking

VRMVTube includes **native GDMP (Godot MediaPipe) integration** for real-time face tracking:

### Tracking Modes

1. **GDMP Native Tracking (Android/Web)**: Real webcam-based face tracking using MediaPipe
   - ✅ **Fully integrated** - no external setup required!
   - Uses MediaPipe's 468-point face mesh and 52 ARKit-compatible blendshapes
   - Automatically requests camera permissions on mobile
   - Works seamlessly on Android and Web platforms

2. **Simulated Tracking (Fallback)**: Built-in animated tracking for demonstration
   - Used automatically on desktop platforms (Windows/macOS/Linux)
   - Also used when GDMP is unavailable or camera permission is denied

### Platform-Specific Tracking

- **Android**: Native GDMP camera with real face tracking ✅
- **Web**: Native GDMP camera with real face tracking ✅
- **Desktop (Windows/macOS/Linux)**: Simulated tracking (GDMP camera not supported in Godot yet)

For advanced desktop face tracking setup, see [tools/README.md](tools/README.md) and [docs/MOTION_CAPTURE.md](docs/MOTION_CAPTURE.md)

## Platform Support

| Platform | Status | Virtual Camera | Face Tracking |
|----------|--------|----------------|---------------|
| Windows  | ✅ Supported | ✅ Yes | Simulated |
| Linux    | ✅ Supported | ✅ Yes | Simulated |
| macOS    | ✅ Supported | ❌ No | Simulated |
| Android  | ✅ Supported | ❌ No | ✅ GDMP Native |
| Web      | ✅ Supported | ❌ No | ✅ GDMP Native |

**Notes:** 
- Virtual camera functionality is only available on Windows and Linux due to platform limitations.
- GDMP native face tracking works on Android and Web with automatic camera access.
- Desktop platforms use simulated tracking (GDMP camera support coming soon).

## Requirements

- Godot 4.3 or newer
- Webcam (for motion tracking)
- VRM model file (.vrm)

## Installation

### From Source

1. Clone this repository:
   ```bash
   git clone --recursive https://github.com/cyanmint/vrmvtube.git
   cd vrmvtube
   ```

2. (Optional) Add a default VRM model:
   ```bash
   # Place your VRM model in the models directory
   # Name it 'default.vrm' for automatic loading on startup
   cp /path/to/your/model.vrm models/default.vrm
   ```

3. Open the project in Godot 4.3+

4. Enable the required plugins in Project Settings → Plugins:
   - MToon
   - vrm

5. Run the project

### Pre-built Releases

Download the latest release for your platform from the [Releases](../../releases) page.

## Usage

1. Launch VRMVTube
2. The app will automatically load the example VRM model (example/cyanmint.vrm)
3. **On Android/Web: Grant camera permission when prompted** - enables real face tracking with GDMP!
4. Your avatar will animate in real-time:
   - **Android/Web**: Real face tracking using your webcam via MediaPipe
   - **Desktop**: Simulated facial expressions (camera support coming soon)
5. Use camera controls:
   - **Drag** to rotate camera
   - **Shift+Drag** to pan camera
   - **Mouse Wheel** to zoom
6. Use model controls (bottom panel):
   - **Position Y slider**: Adjust model height
   - **Scale slider**: Resize the model
   - **Reset Pose button**: Return to default position/scale
7. Load your own VRM model using the "Load VRM Model" button
8. (Windows/Linux only) Enable virtual camera to use your avatar in other applications (feature in development)

**Quick Testing:**
- See `QUICKSTART.md` for step-by-step testing guide
- See `TESTING.md` for comprehensive testing documentation
- See `TROUBLESHOOTING.md` for common issues and solutions
- Run `python3 validate.py` to check project structure before testing

**Known Issues:**
- **Desktop Webcam:** GDMP native camera is not yet supported on desktop platforms in this Godot version. Desktop uses simulated tracking. For webcam-based tracking on desktop, use external tools (see docs/MOTION_CAPTURE.md).
- **Android/Web Webcam Preview:** While face tracking works perfectly with GDMP on Android/Web, the webcam preview in the UI is not yet implemented (only the face tracking data is captured).
- **VRM Textures:** Ensure both VRM and MToon Shader plugins are enabled in Project Settings → Plugins. The app now includes enhanced lighting for better detail visibility.
- **Android Architecture Support:** The APK supports **arm64-v8a** (64-bit ARM devices) and **x86_64** (emulators). 32-bit architectures (armeabi-v7a, x86) are **not supported** due to GDMP MediaPipe library limitations. Most modern Android devices use 64-bit ARM.

### Getting VRM Models

You can get VRM models from:
- **VRoid Hub**: https://hub.vroid.com/ (many free models)
- **VRoid Studio**: https://vroid.com/studio (create your own)
- Or purchase from creators on various platforms

## Building from Source

### Prerequisites

- Godot 4.3+ (with export templates)
- Platform-specific SDKs (for Android builds)

### Export

1. Open the project in Godot
2. Go to Project → Export
3. Select your target platform
4. Click "Export Project"

See `.github/workflows/` for automated CI/CD build configurations.

## Credits and Licenses

This project incorporates code and assets from various sources. We are grateful to the following projects and their contributors:

### Core Dependencies

- **[godot-vrm](https://github.com/V-Sekai/godot-vrm)** by V-Sekai
  - License: MIT License
  - Copyright (c) 2020-2021 V-Sekai Contributors
  - Copyright (c) 2020 VRM Consortium
  - Used for VRM model parsing and import/export functionality
  
- **MToon Shader**
  - License: MIT License
  - Copyright (c) 2018 Masataka SUMI
  - Provides anime-style shader for VRM models

### Inspiration

- **[VRigUnity](https://github.com/Kariaro/VRigUnity)** by Kariaro
  - Inspiration for application design and features
  - No code directly copied

### Godot Engine

- **[Godot Engine](https://godotengine.org/)**
  - License: MIT License
  - Copyright (c) 2007-2021 Juan Linietsky, Ariel Manzur
  - Copyright (c) 2014-2021 Godot Engine contributors

## Project License

This project is licensed under the **CC0 1.0 Universal** license.

Copyright 2025-2026 cyan mint <cyanmint@outlook.com>

Code and content created by GitHub Copilot. See [copying.txt](copying.txt) for details.

**Note:** While this project itself is CC0, the dependencies listed above retain their original licenses (primarily MIT). When distributing this software, ensure compliance with all dependency licenses.

## AI Generation Notice

This project was created by GitHub Copilot. AI-generated content is neither subject to copyright nor covered by any warranty. See [copying.txt](copying.txt) for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Disclaimer

This software is provided "as is" without warranty of any kind. See the license for full details.

## Support

For issues, questions, or discussions, please use the [GitHub Issues](../../issues) page.

## Roadmap

- [x] Basic VRM model loading
- [x] Interactive camera controls (rotate, pan, zoom)
- [x] Model positioning and scaling controls
- [x] Cross-platform support
- [x] CI/CD for automated builds
- [x] Webcam access and preview
- [x] Face tracking (simulated - real tracking in progress)
- [x] Face rigging with VRM blend shapes
- [ ] Real-time face landmark detection (MediaPipe/OpenCV)
- [ ] Hand tracking
- [ ] Virtual camera integration (Windows/Linux)
- [ ] VMC protocol support
- [ ] Custom backgrounds
- [ ] Motion recording/playback
