# GDMP Android Debug Guide

## Issue: Simulated Tracking on Android Instead of Real Face Tracking

If you're seeing simulated tracking on Android instead of real GDMP face tracking, follow this debug guide.

## Step 1: Check Console Logs

Look for these specific messages in the Android logcat:

### Expected Messages (GDMP Working):
```
GDMPAndroid: Loading native library for Android...
GDMPAndroid: Calling System.loadLibrary('GDMP.android')...
GDMPAndroid: ✅ Native library loaded successfully
GDMPTracking: Checking GDMP availability...
GDMPTracking: Platform: Android
GDMPTracking:   - MediaPipeImage: ✅
GDMPTracking:   - MediaPipeFaceLandmarker: ✅
GDMPTracking:   - MediaPipeCameraHelper: ✅
GDMPTracking:   - MediaPipeGPUResources: ✅
GDMPTracking:   - MediaPipeTaskBaseOptions: ✅
GDMPTracking: ✅ GDMP plugin fully available!
Main: ✅ GDMP is available and active!
```

### Problematic Messages (GDMP Not Working):
```
GDMPAndroid: Failed to wrap java.lang.System - not on Android?
GDMPTracking:   - MediaPipeImage: ❌
GDMPTracking: ❌ GDMP plugin NOT available - some classes missing
Main: ⚠️ GDMP not available - using simulated tracking
```

## Step 2: Verify APK Contents

Extract the APK and check if GDMP files are included:

```bash
# Extract APK
unzip VRMVTube.apk -d apk_extracted

# Check for GDMP native libraries
ls -la apk_extracted/lib/arm64-v8a/libGDMP.android.so
ls -la apk_extracted/lib/x86_64/libGDMP.android.so

# Check for model file
ls -la apk_extracted/assets/addons/GDMP/models/face_landmarker.task
```

**Expected:**
- `libGDMP.android.so` should exist for your architecture (arm64-v8a or x86_64)
- `face_landmarker.task` should be ~9.4MB in the assets

**If missing:** The build process didn't include GDMP properly.

## Step 3: Check Build Logs

During CI/CD build, look for:

```
Setting up GDMP for Android...
✓ GDMP binaries installed (all platforms)
✓ MediaPipe model downloaded
Android libraries:
-rw-r--r-- ... libGDMP.android.so (arm64)
```

**If missing:** GDMP download step failed in CI/CD.

## Step 4: Verify Device Architecture

```bash
adb shell getprop ro.product.cpu.abi
```

**Supported architectures:**
- `arm64-v8a` ✅ (64-bit ARM, most modern devices)
- `x86_64` ✅ (64-bit x86, emulators)

**NOT supported:**
- `armeabi-v7a` ❌ (32-bit ARM)
- `x86` ❌ (32-bit x86)

## Step 5: Common Fixes

### Fix 1: Ensure GDMP is Downloaded in Build

In `.github/workflows/build.yml`, the Android export job should have:

```yaml
- name: Download and Setup GDMP
  run: |
    wget -q https://github.com/j20001970/GDMP/releases/download/${GDMP_VERSION}/GDMP-${GDMP_VERSION}.zip
    unzip -o -q GDMP-${GDMP_VERSION}.zip
    mkdir -p addons/GDMP/models
    wget -q -O addons/GDMP/models/face_landmarker.task \
      https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/latest/face_landmarker.task
```

### Fix 2: Verify Export Settings

In `export_presets.cfg` for Android:

```ini
[preset.3]
name="Android"
export_filter="all_resources"  # Include all resources
include_filter=""  # Don't need specific includes
exclude_filter="third_party/*"  # Optional if you keep local sources
architectures/arm64-v8a=true  # 64-bit ARM
architectures/x86_64=true  # Emulator support
```

### Fix 3: Check Plugin Enabled

In `project.godot`:

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/GDMP/plugin.cfg", ...)
```

### Fix 4: Clean and Rebuild

Sometimes cached data causes issues:

```bash
# Clean Godot import cache
rm -rf .godot/

# Rebuild from scratch in CI/CD
```

## Step 6: Test with GDMP Demo

Clone and test the official GDMP demo:

```bash
git clone https://github.com/j20001970/GDMP-demo
cd GDMP-demo
# Open in Godot and export to Android
```

If GDMP demo works but VRMVTube doesn't, the issue is in VRMVTube's export configuration.

If GDMP demo also doesn't work, the issue is with your Godot version or GDMP version compatibility.

## Step 7: Godot Version Check

**Required:** Godot 4.4+ (GDMP.gdextension compatibility_minimum = 4.4)

Check your Godot version:
```bash
godot --version
```

**VRMVTube uses:** Godot 4.6-stable (should work)

## Step 8: GDMP Version Check

**VRMVTube uses:** GDMP v0.6

Verify in `.github/workflows/build.yml`:
```yaml
env:
  GDMP_VERSION: v0.6
```

## Quick Diagnosis

Run this GDScript in Android to check GDMP:

```gdscript
func _ready():
    print("=== GDMP Debug ===")
    print("Platform: ", OS.get_name())
    print("Godot version: ", Engine.get_version_info())
    
    var classes = ["MediaPipeImage", "MediaPipeFaceLandmarker"]
    for c in classes:
        print(c, ": ", "✅" if ClassDB.class_exists(c) else "❌")
    
    # Try to create GDMP object
    var test = ClassDB.instantiate("MediaPipeImage")
    if test:
        print("✅ Can instantiate GDMP classes!")
    else:
        print("❌ Cannot instantiate GDMP classes")
```

## Need More Help?

1. Provide full console log output (first 100 lines after app start)
2. Share APK contents list: `unzip -l VRMVTube.apk | grep -i gdmp`
3. Confirm device architecture: `adb shell getprop ro.product.cpu.abi`
4. Test with GDMP demo to isolate the issue
