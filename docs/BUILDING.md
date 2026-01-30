# Building VRMVTube

This document explains how to build VRMVTube from source, including building GDMP (MediaPipe for Godot) from source.

## Quick Start (Using CI Builds)

The easiest way to get VRMVTube builds is to use the GitHub Actions CI builds:

1. Go to the [Actions tab](https://github.com/cyanmint/vrmvtube/actions)
2. Click on the latest "Build and Export VRMVTube" workflow run
3. Download the artifacts for your platform:
   - `vrmvtube-windows` - Windows build
   - `vrmvtube-linux` - Linux build
   - `vrmvtube-web` - Web build
   - `mediapipe-models` - MediaPipe model files
   - `gdmp-linux-x86_64` - GDMP library built from source

## Prerequisites

### Required Software

- **Godot Engine 4.6 stable** - [Download](https://godotengine.org/download)
- **Python 3.8+** - For GDMP build scripts
- **Git** - For cloning repositories
- **Bazelisk/Bazel** - For building GDMP from source

### Platform-Specific Requirements

**Linux:**
- GCC 7+ or Clang 6+
- Make
- Wget/curl

**Windows:**
- Visual Studio 2019 or newer with C++ tools
- Git Bash or MSYS2
- Environment variable `BAZEL_VC` pointing to VC installation

**macOS:**
- Xcode 12+
- Xcode Command Line Tools

## Building GDMP from Source

VRMVTube requires GDMP (Godot MediaPipe plugin) which must be built from source for full functionality.

### 1. Clone GDMP Repository

```bash
git clone https://github.com/j20001970/GDMP.git
cd GDMP
git submodule update --init --recursive
```

### 2. Install Bazelisk

**Linux/macOS:**
```bash
wget https://github.com/bazelbuild/bazelisk/releases/download/v1.19.0/bazelisk-linux-amd64
chmod +x bazelisk-linux-amd64
sudo mv bazelisk-linux-amd64 /usr/local/bin/bazel
```

**Windows:**
Download from [Bazelisk releases](https://github.com/bazelbuild/bazelisk/releases) and add to PATH.

### 3. Generate Godot Extension API

```bash
# Download Godot 4.6 stable first, then:
godot --headless --dump-extension-api
```

### 4. Setup GDMP Build Environment

```bash
python3 setup.py --api-json path/to/extension_api.json
```

Note: If buildifier download fails, you can continue - it's optional.

### 5. Build GDMP

**For Linux:**
```bash
python3 build.py desktop --type release --output build/linux
```

**For Windows:**
```bash
python3 build.py desktop --type release --output build/windows
```

**For macOS:**
```bash
python3 build.py desktop --type release --output build/macos
```

**For Android:**
```bash
# Requires Android NDK
export ANDROID_NDK_HOME=/path/to/ndk
python3 build.py android --arch arm64-v8a --output build/android
```

**For iOS:**
```bash
python3 build.py ios --output build/ios
```

**For Web:**
```bash
python3 build.py web --output build/web
```

### 6. Copy Built Libraries

Copy the built library to VRMVTube:

```bash
# Linux
cp build/linux/libGDMP.linux.so /path/to/vrmvtube/addons/GDMP/libs/x86_64/

# Windows
cp build/windows/GDMP.windows.dll /path/to/vrmvtube/addons/GDMP/libs/x86_64/

# macOS
cp build/macos/libGDMP.macos.dylib /path/to/vrmvtube/addons/GDMP/libs/x86_64/
```

## Download MediaPipe Models

VRMVTube requires MediaPipe model files for face and hand tracking:

```bash
cd /path/to/vrmvtube
mkdir -p assets/models/mediapipe

# Download hand landmarker model (~7.5 MB)
curl -L -o assets/models/mediapipe/hand_landmarker.task \
  https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task

# Download face landmarker model (~10 MB)
curl -L -o assets/models/mediapipe/face_landmarker.task \
  https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/latest/face_landmarker.task
```

## Building VRMVTube

### 1. Clone VRMVTube Repository

```bash
git clone https://github.com/cyanmint/vrmvtube.git
cd vrmvtube
```

### 2. Open in Godot Editor

```bash
godot --editor --path .
```

Or simply open the project folder in Godot Editor.

### 3. Import Project

The first time you open the project, Godot will import all assets. This may take a few minutes.

### 4. Run the Project

Press F5 or click the Play button in Godot Editor.

## Exporting VRMVTube

### Setup Export Templates

1. In Godot Editor, go to **Editor → Manage Export Templates**
2. Download templates for version 4.6 stable
3. Or download manually:
   ```bash
   wget https://github.com/godotengine/godot/releases/download/4.6-stable/Godot_v4.6-stable_export_templates.tpz
   mkdir -p ~/.local/share/godot/export_templates/4.6.stable
   unzip Godot_v4.6-stable_export_templates.tpz -d ~/.local/share/godot/export_templates/
   mv ~/.local/share/godot/export_templates/templates/* ~/.local/share/godot/export_templates/4.6.stable/
   ```

### Export via Editor

1. Go to **Project → Export**
2. Select the preset for your target platform
3. Click **Export Project**
4. Choose output location
5. Click **Save**

### Export via Command Line

**Windows:**
```bash
godot --headless --export-release "Windows Desktop" builds/windows/vrmvtube.exe
```

**Linux:**
```bash
godot --headless --export-release "Linux/X11" builds/linux/vrmvtube.x86_64
```

**macOS:**
```bash
godot --headless --export-release "macOS" builds/mac/vrmvtube.zip
```

**Android:**
```bash
godot --headless --export-release "Android" builds/android/vrmvtube.apk
```

**Web:**
```bash
godot --headless --export-release "Web" builds/web/index.html
```

## Automated CI/CD Build

VRMVTube includes GitHub Actions workflows for automated builds:

### Workflow: build-and-export.yml

This workflow automatically:
1. Downloads MediaPipe model files
2. Builds GDMP from source (Linux)
3. Tests project import
4. Exports to Windows, Linux, and Web
5. Creates downloadable artifacts

### Triggering Builds

Builds run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch (Actions tab)

### Download Build Artifacts

1. Go to [Actions tab](https://github.com/cyanmint/vrmvtube/actions)
2. Click on latest successful workflow run
3. Scroll to "Artifacts" section
4. Download the platform-specific build

Artifacts are retained for 14 days.

## Troubleshooting

### GDMP Build Issues

**"Cannot find libGLESv2.so":**
- This is expected in headless mode
- The library will work when run with display/GPU

**Bazel build fails:**
- Ensure you have sufficient disk space (>10GB free)
- Try cleaning bazel cache: `bazel clean --expunge`
- Check Bazel version matches MediaPipe requirements

**Submodule errors:**
- Reinitialize submodules: `git submodule update --init --recursive --force`

### VRMVTube Build Issues

**MediaPipe models not found:**
- Download models as described above
- Ensure files are in `assets/models/mediapipe/`
- Check file permissions

**VRM model not loading:**
- Check console for errors
- Verify `assets/models/cyanmint.vrm` exists
- Ensure VRM plugin is enabled

**Export fails:**
- Verify export templates are installed
- Check export presets configuration
- Ensure all dependencies are present

## Platform-Specific Notes

### Linux
- Built libraries require glibc 2.27+ (Ubuntu 18.04+)
- May need to install libGL and libGLES packages
- Flatpak builds should use isolated environment

### Windows
- Requires Visual C++ Redistributable
- MSVC must be in PATH for GDMP build
- Use Git Bash for running build scripts

### macOS
- Requires macOS 10.13+ (High Sierra)
- Must code sign for distribution
- Universal binaries include both x86_64 and arm64

### Android
- Requires Android SDK and NDK
- Minimum API level: 24 (Android 7.0)
- Target API level: 35 (Android 15)
- Permissions: Camera, Internet, Audio

### Web
- Requires HTTPS or localhost for camera access
- WebAssembly must be enabled
- SharedArrayBuffer requires cross-origin isolation headers

## Development Build

For development with hot-reload:

```bash
godot --editor --path . --verbose
```

Enable in editor:
- **Debug → Deploy with Remote Debug**
- **Debug → Small Deploy with Network FS**

## Release Build

For optimized release builds:

1. Set release mode in export preset
2. Enable optimizations:
   - Strip unnecessary data
   - Optimize for size
   - Embed PCK file
3. Export with:
   ```bash
   godot --headless --export-release "Platform" output_path
   ```

## Contributing

When submitting builds:
1. Use CI/CD workflows when possible
2. Include all required dependencies
3. Test on clean environment
4. Document any build changes
5. Update this guide if needed

## Resources

- [Godot Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/index.html)
- [GDMP Build Guide](https://github.com/j20001970/GDMP/blob/main/docs/BUILDING.md)
- [MediaPipe Models](https://developers.google.com/mediapipe/solutions/vision)
- [Bazel Documentation](https://bazel.build/docs)
