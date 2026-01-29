# GDMP (Godot MediaPipe) Integration Guide

## Overview

VRMVTube uses [GDMP](https://github.com/j20001970/GDMP) - a native GDExtension that brings Google MediaPipe to Godot. This provides:

- ✅ **Native Performance**: No Python, runs as compiled code
- ✅ **Cross-Platform**: Windows, Linux, macOS, Android, iOS, Web
- ✅ **Self-Contained**: Binaries included in exports
- ✅ **Face Mesh**: 468 facial landmarks for precise tracking
- ✅ **Hand Tracking**: Full hand pose estimation
- ✅ **Pose Detection**: Full-body tracking support

## Quick Setup

### Option 1: Download Pre-built Release (Recommended)

1. **Download GDMP binaries:**
   - Go to https://github.com/j20001970/GDMP/releases
   - Download the latest release for your platform
   - Look for files like:
     - `GDMP-windows-x86_64.zip`
     - `GDMP-linux-x86_64.zip`
     - `GDMP-macos-universal.zip`
     - `GDMP-android-arm64-v8a.zip`

2. **Extract to addons directory:**
   ```bash
   cd /path/to/vrmvtube
   unzip GDMP-*.zip
   # This will create addons/GDMP/ with binaries
   ```

3. **Enable the plugin:**
   - Open VRMVTube project in Godot
   - Go to Project → Project Settings → Plugins
   - Enable "GDMP"

### Option 2: Build from Source

If pre-built binaries aren't available for your platform:

```bash
cd third_party/GDMP
git submodule update --init --recursive

# Install Bazelisk
# See: https://github.com/bazelbuild/bazelisk

# Build for your platform
python build.py desktop --type release --output ../../addons/GDMP

# Copy to project
# The built addon will be in addons/GDMP/
```

## Integration with VRMVTube

### Tracking Node

VRMVTube includes `gdmp_tracking.gd` which wraps GDMP's FaceLandmarker for easy use:

```gdscript
# Automatically initialized when GDMP is available
@onready var gdmp_tracking = $GDMPTracking

# Tracking data signal
gdmp_tracking.tracking_data_received.connect(_on_tracking_data)
```

### Configuration

Edit `user://vrmvtube_settings.cfg`:

```ini
[tracking]
use_gdmp = true  # Use native GDMP instead of Python
auto_start = true  # Start tracking automatically
```

## Platform-Specific Notes

### Desktop (Windows/Linux/macOS)
- Download platform-specific GDMP release
- Extract to `addons/GDMP/`
- Works out of the box

### Android
- GDMP supports Android natively
- APK will include GDMP binaries automatically
- No special configuration needed
- Uses device camera for tracking

### Web (HTML5)
- GDMP has Web/WASM support
- Requires MediaPipe WASM files
- See GDMP docs for Web deployment

### iOS
- GDMP supports iOS
- Requires iOS build of GDMP
- See GDMP build instructions

## File Structure

After installing GDMP, your project should have:

```
vrmvtube/
├── addons/
│   └── GDMP/
│       ├── GDMP.gdextension
│       ├── plugin.cfg
│       ├── plugin.gd
│       ├── bin/
│       │   ├── windows/
│       │   │   └── libGDMP.windows.template_release.x86_64.dll
│       │   ├── linux/
│       │   │   └── libGDMP.linux.template_release.x86_64.so
│       │   ├── macos/
│       │   │   └── libGDMP.macos.template_release.universal.dylib
│       │   └── android/
│       │       └── libGDMP.android.template_release.arm64-v8a.so
│       └── models/
│           └── face_landmarker.task
├── scripts/
│   └── gdmp_tracking.gd  # VRMVTube's GDMP wrapper
└── third_party/
    └── GDMP/  # Git submodule (source code)
```

## Models

GDMP requires MediaPipe model files. These are included with GDMP releases:

- `face_landmarker.task` - Face mesh model (~26MB)
- `hand_landmarker.task` - Hand tracking model (~14MB)  
- `pose_landmarker.task` - Pose detection model (~28MB)

Models are automatically included in exports.

## CI/CD Integration

The GitHub Actions workflow automatically:
1. Downloads GDMP binaries for each platform
2. Includes them in the build
3. Exports work with GDMP out of the box

See `.github/workflows/build.yml` for details.

## Troubleshooting

### "GDMP plugin not found"
- Download GDMP release and extract to `addons/GDMP/`
- Enable plugin in Project Settings → Plugins

### "Model file not found"
- Ensure `addons/GDMP/models/face_landmarker.task` exists
- Download from GDMP releases if missing

### "GDExtension failed to load"
- Check you downloaded the correct platform binaries
- Ensure DLLs/SOs are in `addons/GDMP/bin/`

### Performance issues
- GDMP is highly optimized, should run smoothly
- Reduce camera resolution if needed
- Check GPU/NPU availability

## Migration from Python Scripts

GDMP replaces the Python-based tracking:

| Old (Python) | New (GDMP) |
|--------------|------------|
| mediapipe_bridge.py | Built-in GDMP |
| openseeface_receiver | Built-in GDMP |
| python_manager.gd | Not needed |
| UDP receivers | Direct API calls |

Benefits:
- ⚡ Faster (native code)
- 📦 Self-contained (no Python)
- 🌍 Works on mobile
- 🔧 Easier to deploy

## Resources

- **GDMP GitHub**: https://github.com/j20001970/GDMP
- **GDMP Releases**: https://github.com/j20001970/GDMP/releases
- **GDMP Docs**: https://github.com/j20001970/GDMP/tree/master/docs
- **MediaPipe**: https://developers.google.com/mediapipe
- **Asset Library**: https://godotengine.org/asset-library/asset/4322

## License

- **GDMP**: Apache 2.0
- **MediaPipe**: Apache 2.0
- **VRMVTube**: CC0 (Public Domain)

---

**Status**: ✅ GDMP provides native, self-contained face tracking for all platforms
