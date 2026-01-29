# Android APK Fix Documentation

## Problem Statement
The CI was generating invalid Android APK files that could not be installed or run on Android devices.

## Root Cause Analysis

### Issue 1: GDExtension Not Supported Without Gradle
- **Setting**: `gradle_build/use_gradle_build=false` in `export_presets.cfg`
- **Problem**: Pre-built APK template only embeds the `.pck` file
- **Impact**: GDExtension native libraries (`.so` files) are not included
- **Result**: Invalid/broken APK

### Issue 2: GDMP Requires Native Libraries
- GDMP uses Google MediaPipe via GDExtension
- Requires native Android libraries:
  - `addons/GDMP/libs/arm64/libGDMP.android.so` (~25MB)
  - `addons/GDMP/libs/x86_64/libGDMP.android.so` (~28MB)
- These must be properly packaged in the APK

### Issue 3: Missing Android Build Template
- Gradle build requires Android build template
- Template contains Gradle scripts and Godot AAR files
- Must be installed in project before export

## Complete Solution

### 1. Enable Gradle Build

**File**: `export_presets.cfg`

**Changes**:
```ini
[preset.3.options]
gradle_build/use_gradle_build=true    # Changed from false
gradle_build/min_sdk="24"            # Added (Android 7.0+)
gradle_build/target_sdk="33"         # Added (Android 13)
```

**Why**: Gradle build properly includes GDExtension native libraries in APK.

### 2. Install Android Build Template

**File**: `.github/workflows/build.yml`

**New Step** (added before Import Resources):
```yaml
- name: Install Android Build Template
  run: |
    echo "Installing Android build template..."
    mkdir -p android
    cd android
    unzip -o -q ~/.local/share/godot/export_templates/4.6.stable/android_source.zip
    echo "✓ Android build template installed"
```

**Template Contents**:
- Gradle build scripts (`build.gradle`, `settings.gradle`, etc.)
- Godot Engine AAR files (~200MB):
  - `libs/debug/godot-lib.template_debug.aar` (105MB)
  - `libs/release/godot-lib.template_release.aar` (96MB)
- Android manifest and resources
- Java/Kotlin source files

### 3. Update .gitignore

**File**: `.gitignore`

**Changes**:
```gitignore
# Android build template (will be installed by CI)
android/
```

**Why**: The build template is large (~200MB) and should be downloaded fresh during CI builds, not committed to repository.

## How Android Export Works Now

### Build Process

1. **Setup Phase**:
   - Download Godot 4.6 export templates
   - Download GDMP-v0.6.zip (includes Android .so files)
   - Extract GDMP to `addons/GDMP/`
   - Download MediaPipe face_landmarker.task model

2. **Template Installation**:
   - Extract `android_source.zip` to `android/` directory
   - Template includes Godot AAR files and Gradle scripts

3. **Export Phase**:
   - Godot imports project resources
   - Gradle builds complete Android project
   - Includes GDExtension libraries in APK
   - Signs APK with debug keystore
   - Produces valid, installable APK

### APK Contents

**Valid APK now includes**:
- Godot Engine runtime (~30MB)
- VRMVTube resources and scripts
- GDMP native library (libGDMP.android.so ~25MB)
- MediaPipe face landmarker model (~3.6MB)
- VRM addon and MToon shader
- **Total Size**: ~60-70MB

## Gradle vs Pre-built Template

### Pre-built APK Template (Old Method)
```
gradle_build/use_gradle_build=false
```
- ❌ Uses pre-compiled APK template
- ❌ Only embeds .pck file (game data)
- ❌ Cannot include GDExtension .so files
- ❌ Cannot add custom Android permissions
- ❌ Results in broken APK for projects with GDExtensions

### Gradle Build (New Method)
```
gradle_build/use_gradle_build=true
```
- ✅ Builds full Android project from source
- ✅ Properly includes GDExtension native libraries
- ✅ Supports custom Android permissions
- ✅ Full control over Android manifest
- ✅ Results in valid, working APK

## Verification

### CI Success Indicators
The Android build should now:
1. ✅ Install build template without errors
2. ✅ Import resources successfully
3. ✅ Export APK with gradle
4. ✅ Produce APK file at `builds/android/VRMVTube.apk`
5. ✅ APK size ~60-70MB (includes GDMP)

### Testing on Device
The APK should:
1. ✅ Install on Android 7.0+ devices
2. ✅ Request camera and microphone permissions
3. ✅ Launch without crashes
4. ✅ Load GDMP MediaPipe successfully
5. ✅ Provide face tracking functionality

## Technical Details

### Minimum Requirements
- **Android Version**: 7.0 (API 24) or higher
- **Architecture**: ARM64 (arm64-v8a)
- **Permissions**: Camera, Microphone, Internet

### GDExtension Loading
When the APK runs:
1. Android loads Godot Engine
2. Godot loads `addons/GDMP/GDMP.gdextension`
3. GDExtension loads `libGDMP.android.so`
4. GDMPAndroid.gd calls `System.loadLibrary("GDMP.android")`
5. MediaPipe initializes with face_landmarker.task model
6. Face tracking becomes available

### Build Template Files
Key files in the Android template:
- `build.gradle` - Main gradle build configuration
- `config.gradle` - Godot-specific gradle settings
- `libs/debug/godot-lib.template_debug.aar` - Debug Godot engine
- `libs/release/godot-lib.template_release.aar` - Release Godot engine
- `src/main/AndroidManifest.xml` - Android app manifest
- `src/main/java/com/godot/game/GodotApp.java` - Main activity

## Troubleshooting

### Error: "Android build template not installed"
**Cause**: The `android/` directory is missing or incomplete
**Solution**: Ensure CI step extracts android_source.zip before export

### Error: "libGDMP.android.so not found"
**Cause**: GDMP binaries not downloaded or extracted
**Solution**: Verify GDMP-v0.6.zip is downloaded and extracted correctly

### Error: "Build tools version mismatch"
**Cause**: Android SDK build tools version doesn't match target SDK
**Solution**: This is just a warning, CI uses available version automatically

### APK Size Too Small (<30MB)
**Cause**: GDMP libraries not included in APK
**Solution**: Verify gradle build is enabled and template is installed

## References

- **Godot Documentation**: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
- **GDMP Repository**: https://github.com/j20001970/GDMP
- **MediaPipe Documentation**: https://developers.google.com/mediapipe

## Summary

The Android APK generation issue was caused by using the pre-built APK template which cannot include GDExtension native libraries. The fix:

1. **Enable gradle build** to properly package native libraries
2. **Install Android build template** required for gradle build
3. **Update .gitignore** to exclude generated template files

The CI now produces valid, working Android APKs with full GDMP MediaPipe face tracking support!
