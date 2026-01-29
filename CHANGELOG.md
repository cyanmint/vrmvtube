# Changelog

All notable changes to VRMVTube will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-01-29

### Added
- **GDMP Binary Integration**: Added pre-built GDMP v0.6 binaries (95MB+) for all platforms
  - Windows (x64)
  - Linux (x64, arm64)  
  - macOS (x64/ARM)
  - Android (ARM)
  - iOS
  - Web (WASM)
- **Hand Tracking**: Implemented `HandTrackingManager` class
  - MediaPipe hand landmarker model (7.8MB) included
  - Real-time hand landmark detection (21 landmarks per hand)
  - Framework for VRM hand bone mapping
- **Face Tracking**: Implemented `FaceTrackingManager` class
  - MediaPipe face landmarker model (3.8MB) included
  - Real-time face landmark detection (478 landmarks)
  - 52 facial blendshapes with VRM mapping
  - Automatic blendshape application to VRM models
- **Camera Preview**: Added 320x240 camera preview in UI
- **Tracking UI**: Start/Stop tracking button with status feedback
- **Documentation**: Comprehensive usage and building instructions

### Changed
- **Godot Version**: Updated from 4.6-dev6 to 4.6 stable
- **Project Structure**: Reorganized UI layout with camera preview
- **CI/CD**: Updated GitHub Actions to use Godot 4.6 stable
- **README**: Updated with detailed usage instructions
- **Building Docs**: Updated for Godot 4.6 stable

### Technical Details
- Repository is now fully self-contained (~125MB)
- MediaPipe models included for offline use
- Hand tracking: 21 landmarks per hand, 60 FPS capable
- Face tracking: 478 landmarks, 52 blendshapes, 30 FPS capable
- Cross-platform binary support ensures consistent behavior

## [0.1.0] - 2026-01-29

### Added
- Initial project setup with Godot 4.6
- VRM model support via godot-vrm addon
- MToon shader support via Godot-MToon-Shader addon
- Default VRM model (cyanmint.vrm, 14.5MB)
- Basic UI with VRM model loading
- Camera and lighting setup
- Export presets for all platforms
- CI/CD workflow for multi-platform builds
- Comprehensive documentation
- MIT license compliance for all dependencies

### Features
- Load and display VRM 0.0 and VRM 1.0 models
- 3D viewport with camera controls
- File dialog for VRM selection
- Status feedback system
- Cross-platform support (Windows, Linux, macOS, Android, Web)

---

## Roadmap

### Planned Features (v0.3.0)
- [ ] VRM hand bone mapping with IK
- [ ] Head rotation from face landmarks
- [ ] VMC protocol support
- [ ] Virtual camera output
- [ ] Recording and playback
- [ ] Performance optimizations
- [ ] Advanced expression controls
- [ ] Settings panel
- [ ] Multiple camera support

### Known Issues
- GDMP requires libGLESv2.so.2 on Linux (typically pre-installed)
- Hand bone mapping not yet connected to VRM skeleton
- Head rotation not yet implemented

### Contributing
See [docs/contributing.md](docs/contributing.md) for guidelines.

---

**Note**: This is a work in progress. Features are being added continuously.
