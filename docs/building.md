# Building VRMVTube

This guide covers how to build VRMVTube for all supported platforms.

## Prerequisites

### All Platforms
- Godot Engine 4.6 or newer
- Git for cloning the repository
- Internet connection for downloading dependencies

### Platform-Specific Requirements

#### Windows
- Windows 10 or newer
- Visual Studio 2019 or newer (for export templates)

#### Linux
- Ubuntu 20.04 or newer (or equivalent)
- Build essentials: `sudo apt install build-essential`

#### macOS
- macOS 11.0 or newer
- Xcode command line tools

#### Android
- Android SDK and NDK
- OpenJDK 11 or newer

#### Web
- Emscripten SDK (emsdk)
- Python 3.x

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/cyanmint/vrmvtube.git
cd vrmvtube
```

### 2. Install Godot Engine

Download Godot 4.6+ from https://godotengine.org/download or use development builds from https://github.com/godotengine/godot-builds/releases

For Linux (development version):
```bash
wget https://github.com/godotengine/godot-builds/releases/download/4.6-dev6/Godot_v4.6-dev6_linux.x86_64.zip
unzip Godot_v4.6-dev6_linux.x86_64.zip
chmod +x Godot_v4.6-dev6_linux.x86_64
```

### 3. Download Export Templates

In Godot Editor:
- Go to Editor → Manage Export Templates
- Download templates for Godot 4.6 (or use development templates)

## Building for Desktop Platforms

### Windows

1. **Editor Build:**
   ```bash
   godot --headless --export-debug "Windows Desktop" builds/windows/vrmvtube.exe
   ```

2. **Release Build:**
   ```bash
   godot --headless --export-release "Windows Desktop" builds/windows/vrmvtube.exe
   ```

### Linux

1. **Editor Build:**
   ```bash
   godot --headless --export-debug "Linux/X11" builds/linux/vrmvtube.x86_64
   ```

2. **Release Build:**
   ```bash
   godot --headless --export-release "Linux/X11" builds/linux/vrmvtube.x86_64
   chmod +x builds/linux/vrmvtube.x86_64
   ```

### macOS

1. **Editor Build:**
   ```bash
   godot --headless --export-debug "macOS" builds/macos/vrmvtube.zip
   ```

2. **Release Build:**
   ```bash
   godot --headless --export-release "macOS" builds/macos/vrmvtube.zip
   ```

## Building for Mobile

### Android

1. **Install Android SDK/NDK**
   - Download Android Studio
   - Install SDK and NDK through SDK Manager

2. **Configure Godot**
   - Editor → Editor Settings → Export → Android
   - Set Android SDK and NDK paths

3. **Build APK:**
   ```bash
   godot --headless --export-release "Android" builds/android/vrmvtube.apk
   ```

## Building for Web

1. **Install Emscripten SDK**
   ```bash
   git clone https://github.com/emscripten-core/emsdk.git
   cd emsdk
   ./emsdk install latest
   ./emsdk activate latest
   source ./emsdk_env.sh
   ```

2. **Build for Web:**
   ```bash
   godot --headless --export-release "Web" builds/web/index.html
   ```

## Automated Builds with CI/CD

This project uses GitHub Actions for automated builds. See `.github/workflows/` for CI configuration.

Builds are automatically triggered on:
- Push to main branch
- Pull requests
- Tagged releases

## Testing Builds

### Desktop
```bash
# Run the built executable
./builds/linux/vrmvtube.x86_64
```

### Android
```bash
# Install on connected device
adb install builds/android/vrmvtube.apk
```

### Web
```bash
# Serve locally
cd builds/web
python3 -m http.server 8000
# Open http://localhost:8000 in browser
```

## Common Build Issues

### Issue: Missing Export Templates
**Solution:** Download templates via Editor → Manage Export Templates

### Issue: Android Build Fails
**Solution:** Ensure Android SDK/NDK paths are correctly configured in Godot settings

### Issue: Web Build Fails
**Solution:** Make sure Emscripten SDK is installed and environment is activated

### Issue: Plugins Not Loading
**Solution:** Ensure plugins are enabled in Project Settings → Plugins

## Distribution

### Creating Release Packages

```bash
# Create distribution archives
cd builds/windows
zip -r ../../vrmvtube-windows.zip *

cd ../linux
tar -czf ../../vrmvtube-linux.tar.gz *

cd ../macos
# macOS builds are already zipped
```

### Release Checklist

- [ ] Version number updated in project.godot
- [ ] CHANGELOG updated
- [ ] All platforms build successfully
- [ ] Tests pass on all platforms
- [ ] Documentation is up-to-date
- [ ] Licenses are properly attributed

## Next Steps

- Read the [Development Guide](development.md) for coding guidelines
- Check [Contributing Guide](contributing.md) for contribution workflow
- See [README](../README.md) for usage instructions
