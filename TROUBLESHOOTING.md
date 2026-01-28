# VRMVTube Troubleshooting Guide

This guide helps resolve common issues with VRMVTube.

## Webcam Issues

### Issue: "Found 0 camera feed(s)" on Windows/Desktop

**Cause:** Godot 4.x's CameraServer has limited support for desktop platforms (Windows, macOS, Linux). It works better on mobile (Android/iOS) and web platforms.

**Solution:** The app now automatically falls back to **simulated tracking** on desktop platforms.

**What this means:**
- ✅ The app will still work
- ✅ Face tracking animations will still play (simulated)
- ✅ All features except webcam preview will function
- ⚠️ No real webcam video feed shown
- ⚠️ Tracking data is simulated, not from your actual face

**For Real Webcam Tracking:**
Future versions will integrate one of these solutions:
1. **MediaPipe** (Google's ML solution) - Best option
2. **OpenCV** via GDExtension
3. **OpenSeeFace** integration
4. **VSeeFace** protocol support

**Current Behavior:**
```
WebcamTracker: Desktop webcam access limited in Godot 4.x
WebcamTracker: Using simulated tracking data
WebcamTracker: For real webcam tracking, use MediaPipe or OpenCV plugin
WebcamTracker: Simulated face tracking started
```

The UI will show:
- Webcam status: "Simulated Tracking"
- Info: "Simulated tracking active"
- The model will still blink, move mouth, and rotate head

## VRM Texture Issues

### Issue: VRM model loads but appears with missing/broken textures

**Symptoms:**
- Model loads successfully (you see it in 3D view)
- Blend shapes work (check console for "Mesh has X blend shapes")
- But the model appears gray/white or has missing textures
- Materials look incorrect

**Causes:**
1. MToon Shader plugin not enabled
2. VRM import settings incorrect
3. Texture compression issues
4. GL Compatibility renderer limitations

**Solutions:**

#### 1. Enable MToon Shader Plugin

The MToon shader plugin **must** be enabled for VRM textures to work:

1. Open Project → Project Settings
2. Go to Plugins tab
3. Enable both:
   - ✅ **VRM** plugin
   - ✅ **MToon Shader** plugin (THIS IS CRITICAL)
4. Restart Godot if needed

**Check project.godot:**
```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/vrm/plugin.cfg", "res://addons/Godot-MToon-Shader/plugin.cfg")
```

#### 2. Reimport VRM Model

If textures still don't show:

1. In Godot's FileSystem panel, find your .vrm file
2. Right-click → Reimport
3. In the Import dock, check these settings:
   - **Ensure textures are imported**
   - **Check material settings**
4. Click "Reimport"
5. Restart the scene (F6) or project (F5)

#### 3. Check Renderer Compatibility

VRMVTube uses GL Compatibility renderer for cross-platform support.

If textures still don't work:
- Try changing to Forward+ renderer (better quality, but desktop-only)
- Edit project.godot:
  ```ini
  [rendering]
  renderer/rendering_method="forward_plus"
  ```
- Note: This will break web/mobile compatibility

#### 4. Texture Compression

Some VRM models use textures that don't compress well:

1. Project Settings → Rendering → Textures
2. Try disabling texture compression:
   ```ini
   textures/vram_compression/import_etc2_astc=false
   ```
3. Restart Godot

#### 5. Check VRM Model Itself

Test if the issue is with the specific VRM model:

1. Open the VRM in **VRoid Studio** or **UniVRM (Unity)**
2. Check if textures show correctly there
3. If not, the VRM file itself may be corrupted
4. Try exporting it again from VRoid Studio
5. Try a different VRM model to isolate the issue

## Other Common Issues

### Issue: Model appears but doesn't animate

**Check:**
1. Console shows "FaceRigging: VRM model set" ✅
2. Console lists blend shapes ✅
3. Signal connections are correct ✅

**Possible causes:**
- Blend shape names don't match (see console output)
- VRM model doesn't have standard blend shapes
- Simulated tracking not running

**Solution:**
Check the blend shape mapping in `scripts/face_rigging.gd`:
```gdscript
const BLEND_SHAPES := {
    "blink_left": "blinkLeft",  # Standard VRM name
    "blink_right": "blinkRight",
    "mouth_open": "aa",
    "mouth_smile": "joy",
    # ... etc
}
```

For non-standard VRM models, you may need to update these mappings to match the blend shape names shown in the console.

### Issue: Camera controls don't work

**Solution:**
- Click on the 3D viewport to give it focus
- Ensure you're clicking on the viewport, not the UI panel
- Try different mouse buttons

### Issue: Performance is poor

**Solutions:**
1. Reduce window size
2. Use a simpler VRM model (fewer polygons)
3. Disable shadows:
   - Select DirectionalLight3D in scene tree
   - Uncheck "Shadow Enabled"
4. Lower texture quality in Project Settings

### Issue: Model is too small/large

**Solution:**
Use the Model Controls panel (right side):
- Adjust the **Scale slider** to resize
- Adjust **Position Y slider** to move up/down
- Click **Reset Pose** to return to defaults

## Getting Help

If issues persist:

1. **Check Console Output:**
   - Look for errors (red) and warnings (yellow)
   - Copy the full console log

2. **Check Godot Version:**
   - Requires Godot 4.3 or newer
   - Check: `godot --version`

3. **Verify Plugin Installation:**
   ```
   addons/
   ├── vrm/
   │   ├── plugin.cfg ✅
   │   └── ... (many files)
   └── Godot-MToon-Shader/
       ├── plugin.cfg ✅
       └── ... (shader files)
   ```

4. **Create an Issue:**
   - Include Godot version
   - Include OS (Windows, macOS, Linux)
   - Include console output
   - Include screenshot if possible
   - Specify VRM model used (if custom)

## Known Limitations

1. **Desktop Webcam:** Limited by Godot 4.x CameraServer
   - Workaround: Uses simulated tracking
   - Future: Will integrate MediaPipe/OpenCV

2. **VRM 0.x vs 1.0:** Different blend shape names
   - Check console output for actual blend shape names
   - Adjust mappings in face_rigging.gd if needed

3. **Mobile Performance:** May be slow on low-end devices
   - Use simpler VRM models
   - Lower texture resolution

4. **Web Browser:** Requires HTTPS for camera access
   - Simulated tracking works on HTTP
   - Real camera needs secure context

## Debug Mode

To enable more detailed logging, edit scripts and add:

```gdscript
# In _process or relevant function
if Engine.get_frames_drawn() % 60 == 0:  # Every 60 frames
    print("Debug: tracking_active=", tracking_active)
    print("Debug: current_blend_shapes=", current_blend_shapes)
```

## Reporting Bugs

When reporting issues, include:
- [ ] Godot version (from console or About menu)
- [ ] Operating system and version
- [ ] GPU model (from console output)
- [ ] Full console output (copy-paste)
- [ ] Steps to reproduce
- [ ] Expected vs actual behavior
- [ ] Screenshot (if visual issue)
- [ ] VRM model used (if not the default)

---

Last updated: 2026-01-28
