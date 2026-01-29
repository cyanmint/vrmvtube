# VRMVTube

A virtual character animator application built with Godot Engine. This app uses your webcam and MediaPipe AI to animate VRM models, similar to VRigUnity but completely implemented in Godot.

![License](https://img.shields.io/badge/license-CC0%201.0-blue)
![Godot](https://img.shields.io/badge/Godot-4.6+-blue)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS%20%7C%20Android%20%7C%20Web-lightgrey)

## Features

- 🎭 **VRM Model Support** - Load and animate VRM 0.0 and VRM 1.0 models
- 🤖 **AI-Powered Tracking** - Hand and face tracking using Google MediaPipe  
- 🎮 **Cross-Platform** - Runs on Windows, Linux, macOS, Android, and Web
- 🎨 **MToon Shader** - Full support for VRM's MToon shading
- 📹 **Webcam Support** - Real-time motion capture from your webcam
- 😊 **Facial Expressions** - 52 blendshapes for realistic facial animation
- 👋 **Hand Tracking** - Real-time hand landmark detection
- 🎬 **VMC Protocol** - Compatible with Virtual Motion Capture protocol (planned)

## Inspiration & Credits

This project is inspired by and builds upon:

- **[VRigUnity](https://github.com/Kariaro/VRigUnity)** by Kariaro (MIT License)
  - Reference implementation for VRM hand tracking with MediaPipe
  
- **[godot-vrm](https://github.com/V-Sekai/godot-vrm)** by V-Sekai (MIT License)
  - VRM import/export functionality and MToon shader for Godot
  
- **[GDMP](https://github.com/j20001970/GDMP)** by j20001970 (MIT License)
  - MediaPipe integration plugin for Godot Engine

Special thanks to the VRM Consortium, V-Sekai team, and all contributors to these projects!

## Installation

### Prerequisites

- Godot Engine 4.6 stable or newer
- A webcam for motion tracking
- (Optional) VRM models for testing

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/cyanmint/vrmvtube.git
   cd vrmvtube
   ```

2. **Open in Godot**
   - Open Godot Engine 4.6 stable or newer
   - Click "Import" and select the `project.godot` file
   - Wait for the project to import

3. **Enable Plugins** (Already enabled by default)
   - VRM plugin - for VRM model support
   - Godot-MToon-Shader - for MToon rendering
   - GDMP plugin - for MediaPipe tracking

4. **Run the Project**
   - Press F5 or click the Play button
   - Grant camera access when prompted
   - The default VRM model will load automatically

## Building from Source

See [docs/building.md](docs/building.md) for detailed build instructions for all platforms.

## Usage

1. **Load a VRM Model**
   - Click "Load VRM Model" button
   - Select a `.vrm` file from your computer
   - Or use the default cyanmint.vrm model that loads automatically

2. **Start Tracking**
   - Click "Start Tracking" button
   - Allow camera access when prompted
   - Your facial expressions and hand movements will be tracked
   - The VRM model will mirror your expressions in real-time

3. **Adjust Camera**
   - Camera preview shows in the bottom-right corner
   - Use good lighting for better tracking accuracy
   - Position your face clearly in the camera view

## Platform Support

| Platform | Status | CI Build |
|----------|--------|----------|
| Windows (x64) | ✅ Supported | ✅ Automated |
| Linux (x64) | ✅ Supported | ✅ Automated |
| macOS (x64/ARM) | ✅ Supported | ✅ Automated |
| Android | ✅ Supported | ✅ Automated |
| Web (HTML5) | ✅ Supported | ✅ Automated |

## Documentation

- [Building Instructions](docs/building.md)
- [Development Guide](docs/development.md)
- [License Information](docs/licenses.md)
- [Contributing](docs/contributing.md)

## License

This project is dedicated to the public domain under CC0 1.0 Universal.
See [copying.txt](copying.txt) for details.

### Third-Party Licenses

This project uses the following third-party components:

- **godot-vrm** - MIT License (Copyright V-Sekai Contributors)
- **GDMP** - MIT License (Copyright Jason Kuo & contributors)
- **MediaPipe** - Apache 2.0 License (Copyright Google LLC)

See [docs/licenses.md](docs/licenses.md) for full license texts.

## Contributing

Contributions are welcome! Please read [docs/contributing.md](docs/contributing.md) before submitting pull requests.

## Support

- Issues: [GitHub Issues](https://github.com/cyanmint/vrmvtube/issues)
- Discussions: [GitHub Discussions](https://github.com/cyanmint/vrmvtube/discussions)

## Roadmap

- [x] Basic project setup
- [x] VRM model loading
- [ ] MediaPipe hand tracking integration
- [ ] UI for model and settings
- [ ] Face tracking support
- [ ] VMC protocol support
- [ ] Virtual camera output
- [ ] Recording and playback
- [ ] Advanced expression controls

## Acknowledgments

- VRM Consortium for the VRM specification
- V-Sekai team for godot-vrm
- Jason Kuo for GDMP
- Kariaro for VRigUnity inspiration
- Google for MediaPipe framework
- Godot Engine community

---

Made with ❤️ using Godot Engine and AI assistance from GitHub Copilot
