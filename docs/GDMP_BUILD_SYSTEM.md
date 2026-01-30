# GDMP Multi-Platform Build System

This document describes the CI/CD system for building GDMP (Godot MediaPipe) from source for all supported platforms.

## Overview

VRMVTube uses two separate CI workflows:

1. **`build-gdmp-multiplatform.yml`** - Builds GDMP libraries from source for all platforms
2. **`build-and-export.yml`** - Uses the built GDMP libraries to export VRMVTube

## Workflow Architecture

### build-gdmp-multiplatform.yml

This workflow builds GDMP from source for:
- **Linux**: x86_64, arm64
- **Windows**: x86_64
- **macOS**: x86_64 (Intel), arm64 (Apple Silicon)
- **Android**: arm64-v8a, x86_64
- **Web**: wasm32

**Triggers:**
- Push to main, develop, or copilot/** branches
- Pull requests to main or develop
- Manual workflow dispatch
- Changes to `.github/workflows/build-gdmp-multiplatform.yml` or `addons/GDMP/**`

**Build Time:** ~20-30 minutes (all platforms in parallel)

**Artifacts:**
- Individual platform libraries (30-day retention)
- Complete GDMP addon (90-day retention)
- Compressed archive of all libraries (90-day retention)

### build-and-export.yml

This workflow builds VRMVTube using GDMP libraries:

1. Downloads MediaPipe models (cached)
2. Downloads GDMP libraries from build-gdmp-multiplatform workflow
3. Tests project import
4. Exports to Windows, Linux, Web

**Fallback:** If GDMP libraries are not available from the build workflow, it uses the prebuilt libraries committed to the repository.

## Platform Build Details

### Linux (x86_64 and arm64)

**Runner:** `ubuntu-latest`

**Tools:**
- Bazelisk 1.19.0
- Python 3.12
- GCC/G++ (for arm64: cross-compilation tools)

**Build Command:**
```bash
python3 build.py desktop --type release --output build/linux-{arch}
```

**Output:** `libGDMP.linux.so` (~30-35 MB)

**Cache:** Bazel build cache (~1-2 GB)

### Windows (x86_64)

**Runner:** `windows-latest`

**Tools:**
- Bazelisk 1.19.0 (Windows version)
- Python 3.12
- MSVC (Visual Studio build tools)

**Build Command:**
```bash
python build.py desktop --type release --output build/windows-x86_64
```

**Output:** `GDMP.windows.dll` (~13 MB)

**Notes:** 
- Bazel on Windows can be slower than Linux
- Uses native Windows build tools

### macOS (x86_64 and arm64)

**Runners:**
- x86_64: `macos-13` (Intel)
- arm64: `macos-latest` (Apple Silicon)

**Tools:**
- Bazelisk (via Homebrew)
- Python 3.12
- Xcode command line tools

**Build Command:**
```bash
python3 build.py desktop --type release --output build/macos-{arch}
```

**Output:** `libGDMP.macos.dylib` (~30-33 MB)

**Notes:**
- Requires separate runners for Intel and Apple Silicon
- Universal binary not currently supported

### Android (arm64-v8a and x86_64)

**Runner:** `ubuntu-latest`

**Tools:**
- Bazelisk 1.19.0
- Python 3.12
- Android SDK
- Android NDK 25.2.9519653
- JDK 17

**Build Command:**
```bash
python3 build.py android --type release --arch {arm64|x86_64} --output build/android-{arch}
```

**Output:** `libGDMP.android.so` (~24-28 MB)

**Architectures:**
- arm64-v8a: Primary (most modern devices)
- x86_64: Emulators and x86 devices

**Notes:**
- armeabi-v7a (32-bit ARM) is not currently built but can be added
- Requires NDK version compatible with MediaPipe

### Web (wasm32)

**Runner:** `ubuntu-latest`

**Tools:**
- Bazelisk 1.19.0
- Python 3.12
- Emscripten SDK (latest)

**Build Command:**
```bash
source emsdk/emsdk_env.sh
python3 build.py web --type release --output build/web
```

**Output:** `GDMP.web.wasm` (~35-40 MB)

**Notes:**
- Requires Emscripten SDK installation
- WASM build is single-threaded by default

## Build Caching Strategy

### Bazel Cache

Each platform uses Bazel's build cache to speed up subsequent builds:

```yaml
- name: Cache Bazel
  uses: actions/cache@v4
  with:
    path: |
      ~/.cache/bazel  # Linux/macOS
      ~/Library/Caches/bazel  # macOS
      ~/_bazel_*  # Windows
    key: bazel-{platform}-{arch}-${{ hashFiles('WORKSPACE', 'BUILD.bazel') }}
    restore-keys: |
      bazel-{platform}-{arch}-
```

**Cache Size:** ~1-2 GB per platform

**Hit Rate:** High for incremental builds, low for clean builds

### MediaPipe Models Cache

MediaPipe model files are cached separately:

```yaml
- name: Cache MediaPipe models
  uses: actions/cache@v4
  with:
    path: assets/models/mediapipe
    key: mediapipe-models-v1
```

**Cache Size:** ~11 MB

**Validity:** Permanent (models don't change often)

## Artifact Management

### Individual Platform Artifacts

**Retention:** 30 days

**Purpose:** Debug individual platform builds

**Usage:** Can be downloaded manually from Actions tab

### Complete GDMP Addon

**Retention:** 90 days

**Purpose:** Full addon with all platform libraries

**Contents:**
```
addons/GDMP/
├── libs/
│   ├── x86_64/
│   │   ├── libGDMP.linux.so
│   │   ├── GDMP.windows.dll
│   │   ├── libGDMP.macos.dylib
│   │   └── libGDMP.android.so
│   ├── arm64/
│   │   ├── libGDMP.linux.so
│   │   ├── libGDMP.macos.dylib
│   │   └── libGDMP.android.so
│   └── GDMP.web.wasm
├── GDMP.gdextension
└── [other addon files]
```

### Library Archive

**Retention:** 90 days

**Format:** `gdmp-libraries-all-platforms.tar.gz`

**Purpose:** Easy download of all libraries in one file

**Size:** ~150-200 MB compressed

## Integration with Main Build

The main build workflow (`build-and-export.yml`) integrates with GDMP builds:

1. **Download GDMP Job:**
   - Attempts to download latest successful GDMP build
   - Uses `dawidd6/action-download-artifact@v3`
   - Falls back gracefully if not available

2. **Fallback Strategy:**
   - If GDMP libraries not downloaded: Uses prebuilt libraries from repository
   - Emits warning but continues build
   - Ensures builds always succeed

3. **Usage in Exports:**
   - Windows export: Uses `GDMP.windows.dll`
   - Linux export: Uses `libGDMP.linux.so` (x86_64)
   - Web export: Uses `GDMP.web.wasm`
   - macOS/Android: Would use respective libraries when those exports are added

## Manual Workflow Dispatch

Both workflows support manual triggering:

1. Go to Actions tab
2. Select `Build GDMP Multi-Platform` or `Build and Export VRMVTube`
3. Click "Run workflow"
4. Select branch
5. Click "Run workflow"

**Use Cases:**
- Rebuild GDMP with latest upstream changes
- Test new platform configurations
- Generate fresh builds for release

## Troubleshooting

### GDMP Build Failures

**Common Issues:**

1. **Bazel Build Timeout**
   - Solution: Increase timeout or use cached build
   - Check: Bazel cache is being used

2. **Submodule Initialization Failed**
   - Solution: Ensure `submodules: recursive` in checkout
   - Check: GDMP repository has all submodules

3. **MediaPipe Dependency Issues**
   - Solution: Update GDMP repository reference
   - Check: MediaPipe version compatibility

4. **Platform-Specific Compiler Errors**
   - Solution: Update NDK/SDK versions
   - Check: Toolchain compatibility

### Integration Issues

**GDMP Not Found:**

```
⚠️ GDMP libraries not found - will use prebuilt libraries from repository
```

This is expected if:
- First time running workflow
- GDMP build workflow hasn't completed yet
- GDMP artifact expired (>30 days old)

**Solution:** Run `build-gdmp-multiplatform.yml` workflow manually

## Build Times

Approximate build times for each platform (with cold cache):

| Platform | Architecture | Time | Notes |
|----------|-------------|------|-------|
| Linux | x86_64 | 12-15 min | Fastest |
| Linux | arm64 | 15-18 min | Cross-compile |
| Windows | x86_64 | 18-22 min | Slower on Windows runner |
| macOS | x86_64 | 15-20 min | Intel runner |
| macOS | arm64 | 15-20 min | Apple Silicon runner |
| Android | arm64-v8a | 18-22 min | Needs NDK |
| Android | x86_64 | 18-22 min | Needs NDK |
| Web | wasm32 | 20-25 min | Emscripten setup |

**Total Parallel Time:** ~25-30 minutes (all platforms build in parallel)

**With Cache:** ~5-10 minutes per platform

## Cost Considerations

GitHub Actions provides free minutes for public repositories:

- Linux: 1x multiplier
- Windows: 2x multiplier
- macOS: 10x multiplier

**Estimated Minutes per Full Build:**
- Linux builds: ~60 minutes (2 platforms × 30 min)
- Windows build: ~40 minutes (× 2 multiplier = 80 billed)
- macOS builds: ~60 minutes (2 platforms × 30 min × 10 multiplier = 600 billed)
- Android builds: ~80 minutes (2 platforms × 40 min)
- Web build: ~25 minutes

**Total:** ~265 actual minutes, ~925 billed minutes per full build

**Recommendation:** Use caching aggressively and only rebuild when needed

## Future Improvements

### Planned Enhancements

1. **Cross-Compilation Matrix**
   - Build all platforms on single runner type
   - Reduce macOS runner usage (expensive)

2. **Incremental Builds**
   - Only build changed platforms
   - Use git diff to detect changes

3. **Binary Caching**
   - Cache compiled MediaPipe libraries
   - Reduce build time by 50%+

4. **Release Automation**
   - Auto-create releases on version tags
   - Include all platform builds

5. **Additional Platforms**
   - iOS (arm64, x86_64 simulator)
   - Android armeabi-v7a (32-bit ARM)
   - Linux arm32

### Optimization Opportunities

1. Use Bazel remote caching
2. Parallelize within platform builds
3. Use faster runners (self-hosted)
4. Reduce artifact sizes with compression

## References

- [GDMP Repository](https://github.com/j20001970/GDMP)
- [MediaPipe](https://developers.google.com/mediapipe)
- [Bazel Build System](https://bazel.build/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Godot GDExtension](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/index.html)
