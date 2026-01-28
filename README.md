# VRMVTube

A cross-platform VTubing application using VRM avatars, built with Godot Engine.

![License: CC0-1.0](https://img.shields.io/badge/License-CC0_1.0-lightgrey.svg)
![Godot 4.3](https://img.shields.io/badge/Godot-4.3-blue.svg)

## Overview

VRMVTube is a VTubing application similar to [VRigUnity](https://github.com/Kariaro/VRigUnity), designed to provide real-time avatar animation using VRM models. This project is built with Godot Engine and supports multiple platforms.

**Key Features:**
- VRM model support (VRM 0.x and 1.0)
- Cross-platform support: Windows, macOS, Linux, Android, and Web
- Webcam-based motion tracking
- Virtual camera output (Windows and Linux only)
- Real-time avatar rendering with MToon shader

## Platform Support

| Platform | Status | Virtual Camera |
|----------|--------|----------------|
| Windows  | ✅ Supported | ✅ Yes |
| Linux    | ✅ Supported | ✅ Yes |
| macOS    | ✅ Supported | ❌ No |
| Android  | ✅ Supported | ❌ No |
| Web      | ✅ Supported | ❌ No |

**Note:** Virtual camera functionality is only available on Windows and Linux due to platform limitations.

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
2. If you placed a `default.vrm` in the models directory, it will load automatically
3. Otherwise, load your own VRM model using the "Load Model" button
4. Allow webcam access when prompted (feature in development)
5. Your avatar will animate based on your movements (feature in development)
6. (Windows/Linux only) Enable virtual camera to use your avatar in other applications (feature in development)

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

See [copying.txt](copying.txt) for the full license text.

**Note:** While this project itself is CC0, the dependencies listed above retain their original licenses (primarily MIT). When distributing this software, ensure compliance with all dependency licenses.

## AI Generation Notice

This project was created with assistance from GitHub Copilot. AI-generated content is neither subject to copyright nor covered by any warranty. See [copying.txt](copying.txt) for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Disclaimer

This software is provided "as is" without warranty of any kind. See the license for full details.

## Support

For issues, questions, or discussions, please use the [GitHub Issues](../../issues) page.

## Roadmap

- [x] Basic VRM model loading
- [x] Cross-platform support
- [x] CI/CD for automated builds
- [ ] Webcam motion tracking
- [ ] Hand tracking
- [ ] Face tracking
- [ ] Virtual camera integration (Windows/Linux)
- [ ] VMC protocol support
- [ ] Custom backgrounds
- [ ] Motion recording/playback
