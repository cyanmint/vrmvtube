# Camera Preview in Settings - Implementation Guide

## Overview

The Settings menu now includes a real-time camera preview in the Camera tab, allowing users to verify their camera selection and see the webcam feed.

## Features

### Real-time Preview
- Live camera feed displayed in 320x240 preview window
- Updates continuously while settings window is open
- Automatically refreshes when camera selection changes

### Multi-source Camera Support
The preview intelligently pulls from multiple camera sources:

1. **GDMP Camera Helper** (Primary - Android/Web/iOS)
   - Uses `GDMPTracking.get_camera_texture()`
   - Works with MediaPipe face tracking
   - Active when GDMP is enabled and camera permission granted

2. **CameraServer** (Fallback - Desktop when available)
   - Uses Godot's CameraServer API
   - Limited support on desktop platforms
   - Creates CameraTexture from selected feed

### Platform-specific Behavior

#### Android/iOS/Web
- Shows live camera feed when:
  - GDMP is initialized
  - Camera permission granted
  - Face tracking active
- Placeholder message: "Camera preview will appear when face tracking is active. Grant camera permission to enable."

#### Desktop (Windows/macOS/Linux)
- Limited camera access in Godot 4.x
- May show feed if CameraServer detects webcam
- Placeholder message: "Desktop webcam access is limited in Godot 4.x. Camera works on Android/Web platforms"

## Implementation Details

### UI Structure

```
Camera Tab
├── Label: "Camera Settings"
├── HSeparator
├── Label: "Select Webcam:"
├── OptionButton (CameraOption)
├── HSeparator
├── Label (InfoLabel) - Platform notes
├── HSeparator
├── Label: "Camera Preview:"
└── PanelContainer (PreviewContainer)
    ├── TextureRect (CameraPreview) - Shows camera feed
    └── Label (PreviewPlaceholder) - Fallback message
```

### Code Architecture

**Initialization (`_ready`):**
```gdscript
1. Get reference to Main scene
2. Get reference to GDMPTracking node
3. Load settings and setup UI
4. Hide window by default
```

**Real-time Updates (`_process`):**
```gdscript
1. Check if settings window is visible
2. If visible, call _update_camera_preview()
3. Preview updates every frame while window open
```

**Preview Update Logic (`_update_camera_preview`):**
```gdscript
1. Try to get camera texture from GDMP tracking
2. If not available, try CameraServer
3. If texture found:
   - Show TextureRect with camera feed
   - Hide placeholder label
4. If no texture:
   - Hide TextureRect
   - Show platform-specific placeholder message
```

**Camera Selection (`_on_camera_selected`):**
```gdscript
1. Update selected camera index in settings
2. Store camera device name
3. Refresh camera preview with new selection
```

## User Experience

### Opening Settings
1. User clicks Settings button or presses 'C'
2. Settings window opens to current tab
3. If on Camera tab, preview starts immediately
4. Real-time feed appears (if available)

### Selecting Camera
1. User opens Camera tab dropdown
2. Selects different camera from list
3. Preview automatically updates to show new camera
4. Changes saved when clicking Save or Apply

### Visual Feedback
- **Active Camera:** Live preview with actual webcam feed
- **No Camera:** Placeholder with helpful message
- **Permission Needed:** Message prompts user to grant permission
- **Desktop Platform:** Message explains limited support

## Technical Notes

### TextureRect Configuration
- `expand_mode = 1` (Keep Size) - Maintains aspect ratio
- `stretch_mode = 5` (Keep Aspect Covered) - Fills container while keeping aspect
- `custom_minimum_size = Vector2(320, 240)` - Standard 4:3 preview size

### Performance
- Preview only updates when settings window is visible
- Uses `_process()` for smooth real-time updates
- Minimal overhead - just texture assignment per frame
- No camera activation - uses existing GDMP camera

### Memory Management
- CameraTexture created on-demand for CameraServer fallback
- Texture reference updates, no duplication
- Placeholder/preview visibility toggled efficiently

## Error Handling

### Scenarios Handled
1. **GDMP node not found** - Falls back to CameraServer
2. **No cameras detected** - Shows "No cameras detected" in dropdown
3. **Camera permission denied** - Shows appropriate message
4. **Desktop platform** - Shows platform limitation message
5. **Settings window closed** - Stops preview updates

### Graceful Degradation
- If GDMP unavailable → Try CameraServer
- If CameraServer empty → Show placeholder
- If node references null → Skip update silently
- Platform detection ensures correct messaging

## Future Enhancements

### Potential Improvements
1. **Refresh Button** - Manual refresh for camera list
2. **Preview Size Options** - User-selectable preview size
3. **Flip/Mirror Toggle** - Preview camera mirroring control
4. **FPS Display** - Show camera frame rate in preview
5. **Resolution Display** - Show current camera resolution
6. **Test Pattern** - Camera test without face tracking

### Desktop Support
If Godot 4.x improves desktop CameraServer support:
- Preview will automatically work on desktop
- No code changes needed
- Platform detection handles it automatically

## Testing Checklist

### Android Testing
- [ ] Install APK on Android device
- [ ] Open Settings → Camera tab
- [ ] Verify permission request appears
- [ ] Grant camera permission
- [ ] Confirm live preview appears
- [ ] Change camera selection
- [ ] Verify preview updates
- [ ] Close and reopen settings
- [ ] Verify preview persists

### Web Testing
- [ ] Open web build in browser
- [ ] Navigate to Settings → Camera
- [ ] Allow camera access in browser
- [ ] Verify preview shows webcam feed
- [ ] Test camera selection dropdown
- [ ] Verify preview updates on change

### Desktop Testing
- [ ] Open on Windows/macOS/Linux
- [ ] Check Settings → Camera tab
- [ ] Verify placeholder message shown
- [ ] Confirm no errors in console
- [ ] Test camera dropdown (if any detected)

## Troubleshooting

### Preview Not Showing
**Symptoms:** Placeholder shown instead of camera feed

**Possible Causes:**
1. Camera permission not granted
2. GDMP not initialized
3. Face tracking not active
4. Wrong camera selected
5. Desktop platform (expected behavior)

**Solutions:**
1. Check console for GDMP initialization messages
2. Verify camera permission granted (Android/Web)
3. Ensure face tracking is active in main scene
4. Try different camera in dropdown
5. Expected on desktop - simulated tracking used

### Preview Frozen
**Symptoms:** Preview shows but doesn't update

**Possible Causes:**
1. Settings window moved to background
2. GDMP camera stopped
3. Camera disconnected

**Solutions:**
1. Ensure settings window is visible (not minimized)
2. Check main scene face tracking is active
3. Reconnect camera or restart app

### Wrong Camera Shown
**Symptoms:** Preview shows different camera than selected

**Possible Causes:**
1. Multiple cameras connected
2. Camera index mismatch
3. CameraServer detection order

**Solutions:**
1. Use dropdown to select correct camera
2. Preview will update automatically
3. Changes saved on Apply/Save

## Code Examples

### Getting Camera Texture
```gdscript
# From GDMP tracking (preferred for Android/Web)
var cam_tex = gdmp_tracking.get_camera_texture()

# From CameraServer (fallback)
var camera_server = CameraServer
var feed = camera_server.get_feed(0)
var cam_tex = CameraTexture.new()
cam_tex.camera_feed_id = feed.get_id()
cam_tex.camera_is_active = true
```

### Updating Preview
```gdscript
if camera_texture:
    camera_preview.texture = camera_texture
    camera_preview.visible = true
    preview_placeholder.visible = false
else:
    camera_preview.visible = false
    preview_placeholder.visible = true
```

### Platform Detection
```gdscript
var platform = OS.get_name()
if platform in ["Android", "iOS", "Web", "HTML5"]:
    # Mobile/web specific code
else:
    # Desktop specific code
```

## Summary

The camera preview feature provides valuable visual feedback to users, helping them:
- Verify camera is working
- Select the correct camera
- Confirm camera permission granted
- See what the face tracking system sees

The implementation is robust, handles multiple platforms gracefully, and degrades gracefully when cameras aren't available.
