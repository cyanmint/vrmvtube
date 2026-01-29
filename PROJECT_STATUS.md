# VRMVTube Project Summary

## Project Overview

VRMVTube is a VTuber application built entirely with Godot Engine 4.6, combining VRM model support and MediaPipe AI tracking. This project is inspired by VRigUnity but completely implemented in Godot for cross-platform support.

## Current Implementation Status

### ✅ Completed Features

1. **Project Setup**
   - Godot 4.6 dev6 project created
   - Project structure organized (scenes/, scripts/, assets/, docs/)
   - Comprehensive .gitignore configuration
   - Export presets for all platforms configured

2. **VRM Support**
   - godot-vrm addon integrated (from V-Sekai)
   - Godot-MToon-Shader addon integrated
   - VRM 0.0 and 1.0 model support
   - Default sample model included (cyanmint.vrm)
   - VRM model loading implemented and tested

3. **UI Implementation**
   - Main scene with 3D viewport
   - Load VRM button functional
   - Status display for user feedback
   - Camera and lighting setup
   - File dialog for VRM selection

4. **Documentation**
   - README.md with project overview
   - docs/building.md with build instructions
   - docs/development.md with architecture details
   - docs/contributing.md with contribution guidelines
   - docs/licenses.md with all third-party attributions
   - .github/copilot-instructions.md for AI development

5. **CI/CD Setup**
   - GitHub Actions workflow configured
   - Multi-platform build support:
     - Windows (x64)
     - Linux (x64)
     - macOS (x64/ARM)
     - Android (ARM)
     - Web (HTML5)

6. **License Compliance**
   - All third-party code properly attributed
   - MIT licenses from godot-vrm, GDMP documented
   - CC0 1.0 Universal for project code
   - License compliance verified

### 🚧 In Progress / TODO

1. **GDMP Integration**
   - GDMP addon copied to project
   - Binary libraries need to be downloaded from GDMP releases
   - MediaPipe tracking not yet implemented
   - Platform-specific binaries needed for:
     - Windows (x64)
     - Linux (x64)
     - macOS (x64/ARM)
     - Android (ARM)
     - Web (WASM)

2. **Tracking Implementation**
   - Hand tracking via MediaPipe (planned)
   - Face tracking via MediaPipe (planned)
   - Connection to VRM bone/blendshape system (planned)
   - Real-time animation updates (planned)

3. **Advanced Features**
   - VMC protocol support (planned)
   - Virtual camera output (planned)
   - Recording and playback (planned)
   - Advanced expression controls (planned)

4. **Testing**
   - Build testing on all platforms needed
   - Performance optimization needed
   - Cross-platform compatibility testing
   - User acceptance testing

## Technical Architecture

### Core Components

1. **Main Scene** (`scenes/main.tscn`)
   - Control-based UI layout
   - SubViewport for 3D VRM rendering
   - Camera3D and DirectionalLight3D
   - Button controls and status labels

2. **Main Script** (`scripts/main.gd`)
   - VRM model loading via PackedScene
   - Plugin detection (VRM, GDMP)
   - UI event handling
   - Status management

3. **Addons**
   - **vrm/**: VRM import/export, extensions
   - **Godot-MToon-Shader/**: MToon rendering
   - **GDMP/**: MediaPipe integration (binaries needed)

### Dependencies

All dependencies use permissive licenses:

| Dependency | License | Purpose |
|------------|---------|---------|
| godot-vrm | MIT | VRM model support |
| Godot-MToon-Shader | MIT | MToon rendering |
| GDMP | MIT | MediaPipe integration |
| MediaPipe | Apache 2.0 | AI tracking |
| Godot Engine | MIT | Game engine |

## Getting Started

### For Users

1. Download release build for your platform
2. Run the application
3. Click "Load VRM Model" to load your avatar
4. Click "Start Tracking" to begin motion capture

### For Developers

1. Clone the repository
2. Open in Godot 4.6+
3. Enable VRM and GDMP plugins
4. Run the project (F5)

See [docs/building.md](docs/building.md) for detailed instructions.

## Next Steps

1. **Download GDMP Binaries**
   - Get pre-built libraries from [GDMP releases](https://github.com/j20001970/GDMP/releases)
   - Place in `addons/GDMP/bin/` for each platform

2. **Implement Tracking**
   - Initialize MediaPipe tasks
   - Set up hand landmark detection
   - Connect landmarks to VRM bones
   - Implement face tracking for expressions

3. **Testing & Optimization**
   - Test on all target platforms
   - Optimize performance
   - Fix platform-specific issues
   - Gather user feedback

4. **Advanced Features**
   - Add VMC protocol support
   - Implement virtual camera
   - Add recording capabilities
   - Create advanced UI

## Known Issues

1. **GDMP Binaries Missing**
   - Error: "GDExtension dynamic library not found"
   - Solution: Download binaries from GDMP releases

2. **Export Templates**
   - CI builds may need export templates
   - Solution: Download Godot 4.6 export templates

## Resources

- **Repository**: https://github.com/cyanmint/vrmvtube
- **V-Sekai godot-vrm**: https://github.com/V-Sekai/godot-vrm
- **GDMP**: https://github.com/j20001970/GDMP
- **VRigUnity (inspiration)**: https://github.com/Kariaro/VRigUnity
- **Godot Engine**: https://godotengine.org/
- **VRM Specification**: https://vrm.dev/

## Credits

- **V-Sekai team** for godot-vrm
- **Jason Kuo (j20001970)** for GDMP
- **Kariaro** for VRigUnity inspiration
- **VRM Consortium** for VRM specification
- **Google** for MediaPipe framework
- **Godot Engine contributors**

## License

This project is dedicated to the public domain under CC0 1.0 Universal.
Third-party components retain their respective licenses (MIT, Apache 2.0).

---

Built with Godot Engine 4.6 and assistance from GitHub Copilot
Last Updated: 2026-01-29
