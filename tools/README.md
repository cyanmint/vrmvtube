# VRMVTube Tools - Self-Contained Face Tracking

## Overview

This directory contains Python-based face tracking tools that work with VRMVTube. These tools are **automatically included** in all desktop builds (Windows, macOS, Linux) to make the application self-contained.

## Platform-Specific Behavior

### Desktop (Windows, macOS, Linux)
- **All tracking methods available**: MediaPipe, OpenSeeFace, VMC
- **Python scripts included** in `tools/` directory
- **Auto-start supported**: Configure in settings to start automatically

### Web
- **JavaScript MediaPipe** runs in browser (no Python needed)
- Use `web_tracking.html` for browser-based tracking
- **VMC receiver** works for external apps

### Android
- **Native implementation**: Uses Android's camera APIs
- **VMC receiver** works over network
- **No Python required**: Self-contained tracking built into APK

## Quick Start

### Option 1: Auto-Start (Easiest)

**Enable in settings:**
```ini
[tracking]
auto_start_openseeface = true
```

**Or edit config manually:**
`user://vrmvtube_settings.cfg`

### Option 2: Manual Start

**Prerequisites (Desktop only):**
```bash
pip install -r requirements.txt
```

**MediaPipe:**
```bash
python mediapipe_bridge.py
```

**OpenSeeFace (if installed separately):**
```bash
git clone https://github.com/emilianavt/OpenSeeFace.git
cd OpenSeeFace
pip install onnxruntime opencv-python pillow numpy
python facetracker.py
```

### Option 3: VMC Protocol

**Use any VMC-compatible app:**
- VSeeFace
- Warudo
- Virtual Motion Capture
- Animaze

**Set output to:** `127.0.0.1:39539`

VRMVTube will automatically receive and use the tracking data.

## Self-Contained Build Structure

### Desktop Builds
```
VRMVTube/
├── VRMVTube.exe (or .x86_64, .app)
└── tools/
    ├── mediapipe_bridge.py
    ├── web_tracking.html
    ├── requirements.txt
    └── README.md (this file)
```

### Android APK
```
VRMVTube.apk (self-contained)
├── Native Android tracking (built-in)
├── VMC receiver (built-in)
└── No external dependencies required
```

### Web Build
```
index.html (includes JavaScript MediaPipe)
└── No installation required
```

## Python Dependencies

Install once with:
```bash
pip install -r requirements.txt
```

**Included dependencies:**
- `mediapipe==0.10.9` - Face mesh tracking
- `opencv-python==4.9.0.80` - Camera access
- `numpy==1.26.4` - Array operations

**Optional (for OpenSeeFace):**
- `onnxruntime` - Neural network runtime
- `pillow` - Image processing

## Tracking Methods Comparison

| Method | Accuracy | Latency | Platform | Auto-Start |
|--------|----------|---------|----------|------------|
| **OpenSeeFace** | ⭐⭐⭐⭐⭐ | 20-40ms | Desktop | ✅ |
| **MediaPipe** | ⭐⭐⭐⭐ | 30-50ms | Desktop/Web | ✅ |
| **VMC Protocol** | ⭐⭐⭐⭐⭐ | 10-20ms | All | N/A (external) |
| **Android Native** | ⭐⭐⭐ | 30-50ms | Android | ✅ (built-in) |
| **Simulated** | N/A | <1ms | All | ✅ (fallback) |

## Configuration

### Settings File
`user://vrmvtube_settings.cfg` (auto-created)

```ini
[tracking]
auto_start_mediapipe = false
auto_start_openseeface = true
preferred_method = "auto"  # auto, openseeface, mediapipe, vmc, simulated
```

### Command-Line Options

**MediaPipe Bridge:**
```bash
python mediapipe_bridge.py --ip 127.0.0.1 --port 9999
```

**Change target:**
```bash
python mediapipe_bridge.py --ip 192.168.1.100 --port 9999
```

## Ports Used

- **9999** - MediaPipe UDP receiver
- **11573** - OpenSeeFace UDP receiver
- **39539** - VMC protocol receiver (Marionette)
- **39540** - VMC protocol sender (Performer)

## Troubleshooting

### Python not found
**Solution:** Install Python 3.8+ from python.org

### No tracking data received
**Checklist:**
1. Python script running? (check console)
2. Firewall blocking UDP? (allow ports above)
3. Correct IP/port? (default: 127.0.0.1)
4. Camera permissions granted?

### High CPU usage
**Solutions:**
- Lower camera resolution
- Reduce tracking FPS
- Close preview window (set SHOW_PREVIEW = False)

### Android tracking not working
- Android uses **built-in native tracking** (no Python needed)
- Grant camera permissions when prompted
- VMC works over WiFi (connect to external tracker)

## Building from Source

### Include Tools in Build

The CI automatically includes tools in all builds. To manually include:

**Windows:**
```bash
mkdir -p builds/windows/tools
cp tools/*.py builds/windows/tools/
cp tools/requirements.txt builds/windows/tools/
```

**Linux:**
```bash
mkdir -p builds/linux/tools
cp tools/*.py builds/linux/tools/
cp tools/requirements.txt builds/linux/tools/
chmod +x builds/linux/tools/*.py
```

**Android:**
No manual steps needed - native tracking is compiled into APK

## License

### VRMVTube
CC0 (Public Domain)

### Dependencies
- **MediaPipe** - Apache 2.0
- **OpenCV** - Apache 2.0
- **NumPy** - BSD License
- **OpenSeeFace** - BSD-2-Clause

All dependencies allow commercial use.

## Support

- **Documentation**: `../docs/MOTION_CAPTURE.md`
- **Quick Start**: `../docs/QUICKSTART_TRACKING.md`
- **Issues**: GitHub repository

---

**Status:** ✅ Fully self-contained builds for all platforms
- Desktop: Python tools bundled
- Android: Native tracking built-in
- Web: JavaScript implementation
