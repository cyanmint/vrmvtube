# Bug Fixes - January 28, 2026

## Issues Resolved

This update fixes critical initialization timing issues that prevented the app from loading properly.

### 1. Webcam Stuck on "Initializing..."

**Problem:**
- Webcam status showed "Initializing..." indefinitely
- Never changed to "Simulated Tracking"
- Signal was emitted before main script could connect to it

**Root Cause:**
The `webcam_available` signal was being emitted during `_ready()` before the main script's `_ready()` had a chance to connect to it. This is a common timing issue in Godot when both parent and child nodes try to communicate during initialization.

**Solution:**
- Changed webcam initialization to use `call_deferred()`
- Ensures signals are connected before emitting
- Main script now connects to signals first, then webcam initializes

**Result:**
- Webcam status now properly shows "Simulated Tracking" on desktop
- Signal communication works correctly
- Status updates happen in the right order

### 2. VRM Model Not Loading

**Problem:**
- Default VRM model (example/cyanmint.vrm) wasn't loading on startup
- Info label stuck on "Loading..."
- No error messages shown

**Root Cause:**
The VRM model loading was happening during `_ready()` before the scene tree was fully initialized. The `load()` function needs the scene tree to be complete.

**Solution:**
- Changed model loading to use `call_deferred("_load_vrm_model", path)`
- Added better error handling and null checks
- Shows helpful message when no model is found

**Result:**
- Default model loads automatically on startup
- Model displays with proper textures and animations
- Clear error messages if model is missing
- Helpful instructions shown when no model loaded

### 3. "Load VRM Model" Button Not Working

**Problem:**
- Button existed but clicking did nothing visible
- File dialog might not open
- Related to model loading timing

**Root Cause:**
Same timing issue as #2 - the scene wasn't fully ready when loading was attempted.

**Solution:**
- Deferred loading ensures scene is ready
- Signal connections verified and working
- File dialog properly centered and functional

**Result:**
- Button now opens file dialog correctly
- Selected VRM models load properly
- Old model replaced when new one loaded

### 4. Platform Shows "Unknown"

**Problem:**
- Platform info label showed "Platform: Unknown" instead of actual OS
- Should show "Platform: Windows (Virtual Camera: Supported)"

**Root Cause:**
@onready variables might not be initialized when accessed. Missing null checks.

**Solution:**
- Added null checks for all UI elements
- Better error messages when elements not found
- Platform detection happens before UI update

**Result:**
- Shows correct platform (Windows, Linux, macOS, etc.)
- Shows virtual camera support status
- Proper error messages if UI elements missing

## Technical Details

### Call Deferred Pattern

The `call_deferred()` function tells Godot to execute a function after the current frame is complete. This ensures:

1. All nodes are fully initialized
2. All @onready variables are set
3. The scene tree is complete
4. Resources can be loaded properly

**Before (Broken):**
```gdscript
func _ready():
    webcam_tracker.webcam_available.connect(_on_webcam_available)
    # ↓ This runs immediately, emitting signal before connection!
    webcam_tracker._initialize_camera()
```

**After (Fixed):**
```gdscript
func _ready():
    # Connect first
    webcam_tracker.webcam_available.connect(_on_webcam_available)
    # Webcam initialization deferred, happens next frame
    # Signal gets emitted after connection is established

# In webcam_tracker.gd:
func _ready():
    call_deferred("_initialize_camera")  # Deferred!
```

### Initialization Order

**Correct Order (Fixed):**
1. Main `_ready()` runs
2. Main connects to `webcam_available` signal
3. WebcamTracker `_ready()` runs
4. WebcamTracker defers `_initialize_camera()`
5. Current frame completes
6. Deferred functions execute
7. `_initialize_camera()` runs
8. Signal emitted (main is already connected!)
9. Main receives signal and updates UI

## Testing the Fixes

### Expected Behavior

When you run the app (F5 in Godot), you should see:

**Console Output:**
```
VRMVTube started
Platform: Windows
Virtual camera is supported on this platform
Main: Connected to webcam signals
Loading default VRM model...
WebcamTracker: Initializing for platform: Windows
WebcamTracker: Attempting camera initialization...
WARNING: WebcamTracker: Desktop webcam access limited in Godot 4.x
WARNING: WebcamTracker: Using simulated tracking data
WebcamTracker: Simulated face tracking started
Loading VRM model from: res://example/cyanmint.vrm
FaceRigging: VRM model set
FaceRigging: Mesh has 57 blend shapes
VRM model loaded successfully
Main: Webcam is not available. Using simulated face tracking.
```

**UI Display:**
- **Platform Info:** "Platform: Windows (Virtual Camera: Supported)"
- **Webcam Status:** "Simulated Tracking"
- **Info Label:** "Simulated tracking active.\nDrag to rotate | Shift+Drag to pan | Scroll to zoom"
- **3D Viewport:** VRM model visible with textures
- **Model Controls:** Position and Scale sliders functional
- **Buttons:** Load VRM Model and Reset Pose clickable

### Quick Test Checklist

- [ ] App starts without errors
- [ ] Platform shows correct OS name
- [ ] Webcam shows "Simulated Tracking" (not "Initializing...")
- [ ] VRM model visible in 3D viewport
- [ ] Model has colors/textures (not gray)
- [ ] Model animates (subtle blinking, head movement)
- [ ] "Load VRM Model" button opens file dialog
- [ ] Can load different VRM models
- [ ] Position Y slider moves model up/down
- [ ] Scale slider makes model bigger/smaller
- [ ] Reset Pose returns model to defaults
- [ ] Camera controls work (drag, shift+drag, scroll)

### If Issues Persist

If you still see problems:

1. **Clear the import cache:**
   - Close Godot
   - Delete `.godot/` folder in project directory
   - Reopen project in Godot
   - Let it reimport everything

2. **Verify plugins are enabled:**
   - Project → Project Settings → Plugins
   - Check: ✅ VRM
   - Check: ✅ MToon Shader
   - Click OK and restart Godot

3. **Check console for errors:**
   - Look for red error messages
   - Check if files are missing
   - Verify example/cyanmint.vrm exists (14.55 MB)

4. **Try loading a different VRM:**
   - Click "Load VRM Model"
   - Select a known-good VRM file
   - See if it loads correctly

## Files Changed

- `scripts/main.gd` - Fixed signal connection order, added deferred loading
- `scripts/webcam_tracker.gd` - Split init into sync/async, added deferred calls

## Related Documentation

- See `TROUBLESHOOTING.md` for more detailed debugging
- See `QUICKSTART.md` for testing instructions
- See `ARCHITECTURE.md` for system design

---

**Status:** All critical initialization bugs fixed ✅  
**Version:** Commit d1c24cc  
**Date:** January 28, 2026
