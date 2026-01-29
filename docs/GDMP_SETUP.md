# GDMP (Godot MediaPipe) - Fully Integrated

## Overview

VRMVTube now has **GDMP source code fully vendored** in this repository. GDMP provides native MediaPipe integration for Godot 4.x.

**Key Features:**
- ✅ **Fully Self-Contained**: Source code included in `third_party/GDMP/`
- ✅ **CI Builds Binaries**: GitHub Actions automatically builds GDMP for all platforms
- ✅ **No Manual Downloads**: Everything automated in CI
- ✅ **Native Performance**: Compiled C++ MediaPipe integration
- ✅ **Cross-Platform**: Windows, Linux, macOS, Android, iOS, Web

## For Developers

### Local Development

GDMP binaries are **NOT** committed to the repo. Instead, CI downloads them during builds.

For local development, you have two options:

#### Option 1: Let CI Download GDMP (Recommended)

The CI workflow automatically downloads GDMP v0.6 binaries and MediaPipe models during build:

```bash
# CI does this automatically:
wget https://github.com/j20001970/GDMP/releases/download/v0.6/GDMP-v0.6.zip
unzip GDMP-v0.6.zip  # Extracts to addons/GDMP/
wget https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/latest/face_landmarker.task
mv face_landmarker.task addons/GDMP/models/
```

#### Option 2: Build GDMP from Source (Advanced)

If you want to build GDMP locally:

```bash
cd third_party/GDMP

# Initialize MediaPipe submodule (GDMP has its own submodules)
git submodule update --init --recursive

# Install Bazelisk (build tool)
# See: https://github.com/bazelbuild/bazelisk

# Build for your platform
python build.py desktop --type release --arch x86_64

# Copy built addon to project
cp -r addons/GDMP ../../addons/
```

**Note:** Building GDMP from source requires:
- Bazel/Bazelisk
- C++ compiler toolchain
- Python 3
- Several GB of disk space
- 30-60 minutes build time

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
├── third_party/
│   └── GDMP/              # ← GDMP source code (vendored)
│       ├── GDMP/          # Source files
│       ├── build.py       # Build script
│       ├── README.md      # GDMP documentation
│       └── ...
├── addons/
│   ├── GDMP/              # ← Built binaries (CI only, not in repo)
│   │   ├── libs/          # Platform-specific .dll/.so/.dylib
│   │   └── models/        # MediaPipe models (downloaded by CI)
│   ├── vrm/               # VRM import/export
│   └── Godot-MToon-Shader/
├── scripts/
│   └── gdmp_tracking.gd   # GDMP integration
└── .github/workflows/
    └── build.yml          # CI: Downloads GDMP binaries
```

## CI/CD Integration

The GitHub Actions workflow (`.github/workflows/build.yml`) automatically:

1. **Checks out the repo** (includes vendored GDMP source)
2. **Downloads GDMP binaries** from GitHub releases
3. **Downloads MediaPipe models** from Google Cloud Storage
4. **Builds all platforms** with GDMP included
5. **Uploads artifacts** - fully self-contained builds

### Why Not Commit Binaries?

- **Large files**: GDMP binaries are ~300MB (all platforms)
- **Git bloat**: Binary files bloat git history
- **License clarity**: Source code shows exact GDMP version
- **Reproducible builds**: CI always gets clean binaries

## Why Vendor Source Code?

1. **Transparency**: Exact GDMP version visible in repo
2. **Stability**: Not affected by upstream changes
3. **License compliance**: GDMP source shows Apache 2.0 license
4. **Customization**: Can modify GDMP if needed
5. **Offline builds**: Can build without internet (once deps cached)

## Updating GDMP

To update to a new GDMP version:

```bash
# Remove old source
rm -rf third_party/GDMP

# Clone new version
git clone --depth 1 --branch vX.X https://github.com/j20001970/GDMP.git third_party/GDMP

# Remove .git to vendor it
rm -rf third_party/GDMP/.git

# Update CI to use new version
# Edit .github/workflows/build.yml:
#   GDMP_VERSION: vX.X

# Commit
git add third_party/GDMP .github/workflows/build.yml
git commit -m "Update GDMP to vX.X"
```

## License

- **GDMP**: Apache 2.0 (source in `third_party/GDMP/`)
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
