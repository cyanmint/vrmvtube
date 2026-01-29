# Camera Input in Godot 4.6 - Complete Guide

## Overview

This document explains how camera input is implemented in VRMVTube using Godot 4.6's CameraServer API and GDMP MediaPipe camera helper across different platforms.

## Platform Support Matrix

| Platform | Camera Support | Implementation | Status |
|----------|---------------|----------------|--------|
| **Android** | ✅ Full | GDMP MediaPipeCameraHelper | Native camera with MediaPipe integration |
| **iOS** | ✅ Full | GDMP MediaPipeCameraHelper | Native camera with MediaPipe integration |
| **Windows** | ✅ Full | CameraServer API | Native webcam support (Godot 4.4+) |
| **Linux** | ✅ Full | CameraServer API | Native webcam support (Godot 4.4+) |
| **macOS** | ✅ Full | CameraServer API | Native webcam support |
| **Web** | ❌ Not Supported | N/A | Requires JavaScript bridge (not implemented) |

## Implementation Details

### Android/iOS - GDMP Camera Helper

**Why GDMP Instead of CameraServer:**
- Better integration with MediaPipe face tracking
- GPU acceleration support
- Permission handling built-in
- Direct frame passing to face landmarker

**Code Flow:**
```gdscript
# 1. Create camera helper
camera_helper = ClassDB.instantiate("MediaPipeCameraHelper")

# 2. Request permission (Android/iOS only)
if not camera_helper.permission_granted():
    camera_helper.request_permission()
    # Wait for user response (up to 10 seconds)

# 3. Set GPU resources (required for MediaPipe)
camera_helper.set_gpu_resources(gpu_resources)

# 4. Start camera
camera_helper.start(0, Vector2(640, 480))  # Front camera, 640x480

# 5. Connect frame callback
camera_helper.new_frame.connect(_on_camera_frame)
```

**Permission Handling:**
- Automatically requests camera permission on Android/iOS
- Polls `permission_granted()` with 10-second timeout
- Shows progress every second
- Emits `camera_failed` signal if denied

### Desktop (Windows/Linux/macOS) - CameraServer

**Why CameraServer:**
- Native Godot API (no external dependencies)
- Supported since Godot 4.4+
- Direct feed access for preview
- Automatic camera detection

**Code Flow:**
```gdscript
# 1. Enable camera monitoring
var camera_server = CameraServer
camera_server.set_monitoring_feeds(true)

# 2. Wait for camera detection
await get_tree().process_frame

# 3. Get available feeds
var feed_count = camera_server.get_feed_count()
var feed = camera_server.get_feed(0)  # First camera

# 4. Activate feed
feed.set_active(true)

# 5. Create texture for display
camera_texture = CameraTexture.new()
camera_texture.camera_feed_id = feed.get_id()
camera_texture.camera_is_active = true
```

**Camera Detection:**
- CameraServer automatically detects connected webcams
- Feeds become available after monitoring is enabled
- May require 1-2 frames for detection
- Feed count can be checked with `get_feed_count()`

### Web Platform - Not Supported

**Limitation:**
CameraServer API does not support Web/HTML5 platform in Godot 4.6.

**Why:**
- Browser security requires JavaScript MediaStream API
- No direct access from WASM/GDScript
- Would need JavaScript bridge implementation

**Potential Solutions:**
1. Implement JavaScript bridge to access browser camera
2. Use HTML overlay with `<video>` element
3. Use GDNative/GDExtension with Emscripten bindings

**Current Behavior:**
- Shows clear message: "CameraServer not supported on Web"
- Falls back to simulated tracking
- No camera permission requested

## Camera Preview in Settings

The settings menu includes a real-time camera preview that shows different content based on platform:

### Preview Sources

**Priority Order:**
1. **GDMP Camera** (Android/iOS) - via `gdmp_tracking.get_camera_texture()`
2. **CameraServer** (Desktop) - via `CameraTexture` from feed
3. **Placeholder** - when no camera available

### Preview Update Logic

```gdscript
func _update_camera_preview():
    # Try GDMP first (Android/iOS)
    var texture = gdmp_tracking.get_camera_texture()
    
    # Try CameraServer (Desktop)
    if not texture:
        var feed = camera_server.get_feed(selected_index)
        if feed:
            feed.set_active(true)
            texture = create_camera_texture(feed)
    
    # Update display
    if texture:
        camera_preview.texture = texture
        show_preview()
    else:
        show_placeholder()
```

### Placeholder Messages

**Android/iOS:**
- "Camera will appear when face tracking is active"
- "Grant camera permission to enable"
- "Waiting for camera... check console logs"

**Desktop:**
- "No camera feed available"
- "Check if webcam is connected and accessible"

**Web:**
- "CameraServer not supported"
- "Requires JavaScript bridge for camera access"

## Troubleshooting

### No Camera Detected (Desktop)

**Symptoms:**
- Settings shows "No cameras detected"
- Camera preview shows placeholder

**Possible Causes:**
1. No webcam connected
2. Webcam in use by another application
3. Camera drivers not installed
4. Permissions not granted (Linux)

**Solutions:**
1. Check physical webcam connection
2. Close other apps using camera (Zoom, Skype, etc.)
3. Update camera drivers
4. Grant camera access (Linux: check `/dev/video*` permissions)

### Permission Denied (Android)

**Symptoms:**
- Console shows "Camera permission DENIED"
- Face tracking uses simulated mode

**Possible Causes:**
1. User denied permission in dialog
2. Permission not declared in AndroidManifest
3. Android version restrictions

**Solutions:**
1. Go to Android Settings → Apps → VRMVTube → Permissions
2. Enable Camera permission
3. Restart app

### Camera Not Working (Android with Permission)

**Symptoms:**
- Permission granted but no camera feed
- Console shows errors about camera initialization

**Possible Causes:**
1. GDMP library not properly loaded
2. GPU resources not initialized
3. Camera hardware issue
4. Wrong camera index

**Solutions:**
1. Check console for GDMP initialization errors
2. Verify GDMP plugin is enabled in Project Settings
3. Try different camera index (0 for front, 1 for back)
4. Restart device

## Performance Considerations

### Desktop (CameraServer)

**Resource Usage:**
- `set_monitoring_feeds(true)` has performance cost
- Only enable when needed
- Disable when settings closed

**Optimization:**
```gdscript
# Enable only when needed
func show_settings():
    CameraServer.set_monitoring_feeds(true)

# Disable when done
func hide_settings():
    CameraServer.set_monitoring_feeds(false)
```

### Mobile (GDMP)

**Resource Usage:**
- Camera helper uses GPU acceleration
- Frame callbacks fired at camera FPS (usually 30fps)
- MediaPipe processing happens per frame

**Optimization:**
- Use lower resolution (640x480 vs 1920x1080)
- Front camera typically lower power than back
- GPU resources shared with face tracking

## Code References

### Key Files

- `scripts/gdmp_tracking.gd` - Main camera initialization
- `scripts/settings_menu.gd` - Camera preview and selection
- `export_presets.cfg` - Camera permissions (Android)

### Key Functions

**gdmp_tracking.gd:**
- `_initialize_camera()` - Platform-specific camera setup
- `_on_camera_frame(image)` - Frame callback (GDMP)
- `get_camera_texture()` - Returns camera texture for preview

**settings_menu.gd:**
- `_populate_cameras()` - Detect and list cameras
- `_update_camera_preview()` - Update preview display
- `_on_camera_selected(index)` - Handle camera selection

### Signals

**gdmp_tracking.gd:**
- `camera_started` - Emitted when camera successfully starts
- `camera_failed(reason)` - Emitted when camera fails to start

## Future Improvements

### Web Platform Support

**Option 1: JavaScript Bridge**
```javascript
// JavaScript side
navigator.mediaDevices.getUserMedia({ video: true })
    .then(stream => {
        // Send frames to Godot via Module.ccall
    });
```

**Option 2: HTML Overlay**
```html
<!-- HTML overlay with video element -->
<video id="camera" autoplay></video>
<canvas id="output"></canvas>
```

### Multi-Camera Support

**Current:**
- Single camera selection
- Index 0 (default/front)

**Proposed:**
- Dropdown to select camera
- Switch between front/back on mobile
- Remember user preference

### Camera Settings

**Possible Additions:**
- Resolution selection
- FPS adjustment
- Mirror/flip toggle
- Brightness/contrast controls

## Testing

### Desktop Testing

```bash
# Linux - Check available cameras
ls /dev/video*

# Test in Godot
godot --verbose  # See camera detection logs
```

### Android Testing

1. Install APK on device
2. Grant camera permission when prompted
3. Check logcat for camera initialization:
```bash
adb logcat | grep -i "gdmptracking\|camera"
```

### Console Logs to Look For

**Success (Desktop):**
```
GDMPTracking: Using CameraServer for Windows
GDMPTracking: Camera monitoring enabled
GDMPTracking: Detected 1 camera feed(s)
GDMPTracking: Using camera: Integrated Webcam
GDMPTracking: Camera feed activated
GDMPTracking: Camera texture created
GDMPTracking: ✅ CameraServer camera started successfully!
```

**Success (Android):**
```
GDMPTracking: Using GDMP camera helper for Android
GDMPTracking: Checking camera permission status...
GDMPTracking: ✅ Camera permission GRANTED by user!
GDMPTracking: Starting camera (index: 0, resolution: (640, 480))...
GDMPTracking: ✅ GDMP camera started successfully!
GDMPTracking: 📹 Camera active - received 60 frames (30 fps)
```

## Summary

VRMVTube uses a hybrid approach for camera input:
- **GDMP** on Android/iOS for MediaPipe integration
- **CameraServer** on desktop for native webcam access
- **Clear messaging** on Web about lack of support

This provides the best experience on each platform while working within Godot 4.6's capabilities.
