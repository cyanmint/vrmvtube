# GDMP (Godot MediaPipe) - Fully Integrated

## Overview

VRMVTube uses **GDMP prebuilt binaries** from the official releases. The repository keeps only the addon configuration files, while CI (and local developers) download the platform binaries and models as needed.

**Key Features:**
- ✅ **Prebuilt Binaries**: Downloaded from GDMP releases (CI handles this)
- ✅ **No Source Checkout**: No vendored GDMP source required
- ✅ **Native Performance**: Compiled C++ MediaPipe integration
- ✅ **Cross-Platform**: Windows, Linux, macOS, Android, iOS, Web

## For Developers

### Local Development

GDMP binaries are **NOT** committed to the repo. Instead, CI (and local developers) download them during builds.

For local development, download the prebuilt GDMP release and MediaPipe model:

```bash
# Download the unified GDMP release archive
wget https://github.com/j20001970/GDMP/releases/download/v0.6/GDMP-v0.6.zip
unzip GDMP-v0.6.zip  # Extracts to addons/GDMP/

# Download MediaPipe face landmarker model
mkdir -p addons/GDMP/models
wget -O addons/GDMP/models/face_landmarker.task \
  https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/latest/face_landmarker.task
```

## For End Users

**No setup required!**

Downloaded builds already include GDMP binaries and models:
- Windows .exe
- Linux binary
- macOS .app
- Android .apk
- Web (WASM)

Just run the app - face tracking works immediately!

## Repository Structure

```
vrmvtube/
├── addons/
│   ├── GDMP/              # ← Addon config (binaries downloaded)
│   │   ├── GDMP.gdextension
│   │   ├── plugin.cfg
│   │   ├── libs/          # Platform-specific .dll/.so/.dylib
│   │   └── models/        # MediaPipe models
│   ├── vrm/               # VRM import/export
│   └── Godot-MToon-Shader/
├── scripts/
│   └── gdmp_tracking.gd   # GDMP integration
└── .github/workflows/
    └── build.yml          # CI: Downloads GDMP binaries
```

## CI/CD Integration

The GitHub Actions workflow (`.github/workflows/build.yml`) automatically:

1. **Checks out the repo**
2. **Downloads GDMP binaries** from GitHub releases
3. **Downloads MediaPipe models** from Google Cloud Storage
4. **Builds all platforms** with GDMP included
5. **Uploads artifacts** - fully self-contained builds

### Why Not Commit Binaries?

- **Large files**: GDMP binaries are ~300MB (all platforms)
- **Git bloat**: Binary files bloat git history
- **Reproducible builds**: CI always gets clean binaries

## Updating GDMP

To update to a new GDMP version:

```bash
# Update CI to use the new version
# Edit .github/workflows/build.yml:
#   GDMP_VERSION: vX.X

# Download the matching release locally if needed
wget https://github.com/j20001970/GDMP/releases/download/vX.X/GDMP-vX.X.zip
unzip GDMP-vX.X.zip
```

## License

- **GDMP**: Apache 2.0 (prebuilt binaries)
- **MediaPipe**: Apache 2.0
- **VRMVTube**: CC0 (Public Domain)

All compatible for commercial use!

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
│       ├── libs/
│       │   ├── x86_64/
│       │   │   ├── GDMP.windows.dll
│       │   │   └── libGDMP.linux.so
│       │   ├── arm64/
│       │   │   └── libGDMP.android.so
│       │   └── ...
│       └── models/
│           └── face_landmarker.task
├── scripts/
│   └── gdmp_tracking.gd  # VRMVTube's GDMP wrapper
```

## Models

GDMP requires MediaPipe model files. Download them alongside the GDMP binaries:

- `face_landmarker.task` - Face mesh model (~26MB)
- `hand_landmarker.task` - Hand tracking model (~14MB)  
- `pose_landmarker.task` - Pose detection model (~28MB)

CI downloads the model automatically during builds, and exports include it.

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
- Ensure DLLs/SOs are in `addons/GDMP/libs/`

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
