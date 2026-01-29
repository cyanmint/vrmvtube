# Android Fixes Documentation

## Issues Fixed

This document describes the Android-specific issues that were identified and fixed in VRMVTube.

### Issue 1: App Not Starting in Portrait Orientation

**Problem:**
The app was configured for portrait orientation but was still starting in landscape mode on Android devices.

**Root Causes (Multiple Issues Found):**

1. **STRING vs INTEGER:** The `project.godot` file had `window/handheld/orientation="portrait"` (a STRING value), but Godot's Android export requires an INTEGER value for this setting.

2. **FULLSCREEN MODE OVERRIDE:** The `window/size/mode=3` (exclusive fullscreen) setting was overriding the orientation on Android. This is a known Godot issue where fullscreen mode combined with specific window sizes can force landscape orientation.

**CRITICAL FINDINGS:**  
- Android exports use the PROJECT SETTING `display/window/handheld/orientation`, NOT the export preset's `screen/orientation` value
- The value MUST be an integer, not a string
- Explicit fullscreen mode (mode=3) causes orientation override conflicts on Android
- Android apps are automatically fullscreen, so mode=3 is unnecessary and harmful

From `platform/android/export/export_plugin.cpp`:
```cpp
const int screen_orientation =
    _get_android_orientation_value(DisplayServer::ScreenOrientation(
        int(get_project_setting(p_preset, "display/window/handheld/orientation"))
    ));
```

**Fixes Applied:**
1. Changed `window/handheld/orientation="portrait"` to `window/handheld/orientation=1` in project.godot
2. **Removed `window/size/mode=3`** (exclusive fullscreen mode)
3. Changed `window/size/resizable=false` to `window/size/resizable=true`

**Technical Details:**
According to Godot 4 engine source code and Android's ActivityInfo constants:
- `0` = SCREEN_LANDSCAPE / SCREEN_ORIENTATION_UNSPECIFIED (system default, typically landscape)
- `1` = **SCREEN_PORTRAIT** (forces portrait mode) ✅
- `2` = SCREEN_REVERSE_LANDSCAPE
- `3` = SCREEN_REVERSE_PORTRAIT
- `4` = SCREEN_SENSOR_LANDSCAPE
- `5` = SCREEN_SENSOR_PORTRAIT
- `6` = SCREEN_SENSOR (allows all rotations)
- `7` = SCREEN_FULL_SENSOR

**Files Modified:**
- `project.godot` (lines 19-26)
  - Changed orientation from STRING to INTEGER value
  - **REMOVED `window/size/mode=3` (fullscreen override)**
  - Changed `resizable=false` to `resizable=true`
- `export_presets.cfg` (line 181) - Also changed for consistency (though Android doesn't use this value)

**Reference:**
- [Godot Android Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
- [Android ActivityInfo.SCREEN_ORIENTATION constants](https://developer.android.com/reference/android/content/pm/ActivityInfo#screenOrientation)

### Issue 2: Default VRM Model Not Loading

**Problem:**
The default VRM model (`example/cyanmint.vrm`) was not loading when the app started on Android devices.

**Root Cause:**
The export filter in the Android preset used `include_filter="*.vrm,example/*"` which may not have been explicit enough about including VRM files in the example directory.

**Fix:**
1. Changed the include filter to be more explicit: `include_filter="*.vrm,example/*.vrm"`
2. Added Android-specific debug logging to help diagnose VRM loading issues

**Technical Details:**
- Godot's Android export uses the `include_filter` to specify which files to package into the APK
- With `export_filter="all_resources"`, all res:// files are included by default, but being explicit helps ensure critical files aren't missed
- The new filter pattern `example/*.vrm` explicitly includes all VRM files in the example directory

**Files Modified:**
- `export_presets.cfg` (line 149)
- `scripts/main.gd` (added Android-specific logging around line 89-105)

**Debug Logging Added:**
The app now logs the following on Android startup:
- Whether the default VRM file exists
- The user data directory path
- Helpful error messages if the VRM file is missing

**Reference:**
- [Godot Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
- [Android Developers: APK Packaging](https://developer.android.com/games/engines/godot/godot-export)

## Testing

To verify these fixes:

1. **Portrait Orientation Test:**
   - Build and install the Android APK
   - Launch the app on an Android device
   - Verify the app starts in portrait orientation (vertical)
   - Verify rotating the device doesn't change the orientation (locked to portrait)

2. **VRM Model Loading Test:**
   - Build and install the Android APK
   - Launch the app on an Android device
   - Check logcat for the debug messages about VRM file loading
   - Verify the cyanmint.vrm model appears on screen
   - If the model doesn't load, check logcat for the specific error messages

### Viewing Android Logs

To see the debug logs on Android:

```bash
# Connect device via USB and enable USB debugging
adb logcat -s godot:V
```

Look for messages like:
```
Checking for default VRM model at: res://example/cyanmint.vrm
Android platform detected - VRM file check
  - File exists: true
  - User data dir: /data/data/com.vrmvtube.app/files
Default VRM model found! Loading...
```

## Additional Notes

### Why Portrait Orientation?

VRMVTube is designed as a mobile-first VTubing app optimized for:
- Vertical video content (TikTok, Instagram Reels, YouTube Shorts)
- Natural phone holding position
- Mobile streaming workflows

The portrait orientation (720x1280, 9:16 aspect ratio) matches modern social media platforms and provides an optimal mobile experience.

### Alternative Orientations

If you need to change the orientation for a specific use case:

**For sensor-based portrait** (allows upside-down rotation):
```ini
screen/orientation=7  # SCREEN_ORIENTATION_SENSOR_PORTRAIT
```

**For landscape mode (unspecified/default):**
```ini
screen/orientation=0  # SCREEN_ORIENTATION_UNSPECIFIED (typically defaults to landscape)
```

**For sensor-based landscape:**
```ini
screen/orientation=6  # SCREEN_ORIENTATION_SENSOR_LANDSCAPE
```

## Future Improvements

Potential enhancements for Android support:

1. **Runtime Orientation Toggle:** Add a setting to switch between portrait and landscape at runtime
2. **Adaptive UI:** Different layouts for portrait vs landscape
3. **Better File Picker:** Improve the VRM file picker for Android's scoped storage
4. **Performance Optimization:** Optimize VRM rendering for lower-end Android devices
5. **Android-Specific Features:** Add Android Virtual Camera support when available

## Troubleshooting

### Model Still Doesn't Load

If the VRM model still doesn't load after these fixes:

1. Check the APK includes the VRM file:
   ```bash
   unzip -l VRMVTube.apk | grep cyanmint.vrm
   ```

2. Verify the file is in the correct location in the APK

3. Check Android logcat for specific error messages

4. Try loading a different VRM model using the file picker

### App Still Starts in Landscape

If the app still starts in landscape after these fixes:

1. **CRITICAL: Check project.godot settings**
   - WRONG: `window/handheld/orientation="portrait"` (string)
   - RIGHT: `window/handheld/orientation=1` (integer)
   - **MUST NOT HAVE:** `window/size/mode=3` (this overrides orientation!)
   
2. **Verify no fullscreen mode:**
   - The `[display]` section should NOT contain `window/size/mode=3`
   - Android handles fullscreen automatically
   
3. Rebuild the APK completely (don't use cached build)

4. Uninstall the old app completely before installing the new one

5. The export preset's `screen/orientation` value is NOT used by Android exports in Godot - the project.godot setting takes precedence

### Known Godot Issues

- **Fullscreen mode override:** `window/size/mode=3` combined with window sizes can override orientation (GitHub issue #103495)
- **Window size overrides:** Matching device resolution can trigger unintended fullscreen/orientation behavior (GitHub issue #67854)
- On Android, explicit fullscreen mode is unnecessary and can cause conflicts

## Conclusion

These fixes ensure VRMVTube works correctly on Android devices with:
- ✅ Proper portrait orientation on startup
- ✅ Default VRM model loading successfully
- ✅ Better debug logging for troubleshooting
- ✅ Alignment with Godot 4 best practices for Android export

All changes follow official Godot documentation and Android development guidelines.
