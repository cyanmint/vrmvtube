# Developer Quick Start Guide

This guide helps developers quickly test the VRMVTube implementation.

## Prerequisites

- Godot 4.3 or newer
- Python 3 (for validation script)
- A webcam (optional, but recommended for full testing)

## Quick Validation

Before opening in Godot, run the validation script:

```bash
python3 validate.py
```

This checks:
- All required files are present
- Script references are valid
- Signal connections are properly configured
- Project structure is correct

## Testing in Godot

### Step 1: Open Project

1. Launch Godot 4.3+
2. Click "Import" or "Scan" for existing projects
3. Navigate to the `vrmvtube` directory
4. Select `project.godot`
5. Click "Import & Edit"

### Step 2: Enable Plugins

1. Go to **Project → Project Settings**
2. Select the **Plugins** tab
3. Ensure **vrm** plugin is enabled (checkbox should be checked)
4. If not enabled, check the box next to "vrm"
5. Close Project Settings

### Step 3: Run the Project

1. Press **F5** or click the **Play** button (▶️) at the top-right
2. Grant webcam permissions if prompted

### Step 4: Verify Core Features

#### ✅ Model Viewing and Positioning

**Expected:**
- VRM model (cyanmint.vrm) loads automatically
- Model is visible and properly lit
- Model is centered in the view

**Test Camera Controls:**
- **Left-click and drag**: Rotate camera around model
- **Shift + Left-click and drag**: Pan camera
- **Mouse wheel**: Zoom in/out

**Test Model Controls:**
- Look for the "Model Controls" panel at the bottom center
- **Position Y slider**: Drag to move model up/down
  - Label should update with current value
  - Model should move smoothly
- **Scale slider**: Drag to scale model
  - Label should update with current value
  - Model should scale uniformly
- **Reset Pose button**: Click to reset model
  - Model should return to original position and scale

#### ✅ Face Motion Capture via Webcam

**Expected:**
- Webcam preview panel appears in **top-right corner**
- Shows "Webcam Preview" title
- Displays live camera feed (if webcam available)
- Status shows "Tracking Active" (green)

**If no webcam:**
- Status shows "No Webcam"
- Warning in console

**Check Console:**
```
WebcamTracker: Initializing for platform: [Platform]
WebcamTracker: Found X camera feed(s)
WebcamTracker: Using camera: [Camera Name]
WebcamTracker: Camera activated
WebcamTracker: Face tracking started
```

#### ✅ Face Rigging

**Expected:**
- Model face should show **subtle animations**:
  - Periodic blinking (eyes close and open)
  - Slight mouth movement
  - Gentle head rotation (left-right, up-down)
- All movements should be **smooth** (no jerking)

**Check Console:**
```
FaceRigging: VRM model set
FaceRigging: Mesh has X blend shapes
  - blinkLeft
  - blinkRight
  - aa
  - joy
  - ... (other blend shapes)
```

## Common Issues & Solutions

### Issue: Model doesn't load

**Solution:**
- Check that `example/cyanmint.vrm` exists
- Check console for error messages
- Try loading a different VRM model via "Load VRM Model" button

### Issue: No webcam preview

**Solution:**
- Ensure webcam is connected
- Grant permissions when prompted
- Check if webcam works in other apps
- Check console for "WebcamTracker" errors

### Issue: No face animation

**Solution:**
- Verify model has blend shapes (check console output)
- Ensure tracking is active (webcam preview shows "Tracking Active")
- Check that signals are connected (should be automatic)

### Issue: Jerky movement

**Solution:**
- Adjust `smoothing_factor` in `scripts/face_rigging.gd` (line 12)
- Lower value = faster response, more jerky
- Higher value = slower response, smoother
- Default: 0.3

### Issue: Camera controls not working

**Solution:**
- Click on the 3D viewport to ensure it has focus
- Try different mouse buttons
- Check console for input errors

## Manual Testing Checklist

Use this checklist for thorough testing:

- [ ] Project opens without errors
- [ ] VRM plugin is enabled
- [ ] Default VRM model loads automatically
- [ ] Model is visible and properly positioned
- [ ] Camera rotation works (drag)
- [ ] Camera pan works (Shift + drag)
- [ ] Camera zoom works (mouse wheel)
- [ ] Position Y slider moves model
- [ ] Scale slider scales model
- [ ] Reset Pose button resets model
- [ ] Webcam preview appears
- [ ] Webcam shows live feed (or "No Webcam" message)
- [ ] Model shows blinking animation
- [ ] Model shows mouth movement
- [ ] Model shows head rotation
- [ ] All movements are smooth
- [ ] "Load VRM Model" button opens file dialog
- [ ] Can load different VRM models
- [ ] No errors in console (warnings OK)

## Performance Notes

- First load may take a few seconds (loading VRM model)
- Webcam initialization may take 1-2 seconds
- If performance is poor:
  - Reduce window size
  - Close other apps using webcam
  - Try a simpler VRM model

## Next Steps

After basic testing:

1. Read `TESTING.md` for detailed testing procedures
2. Try loading your own VRM models
3. Experiment with camera controls
4. Check the roadmap in `README.md` for upcoming features

## Reporting Issues

If you find bugs or issues:

1. Check console output for errors
2. Note the Godot version and OS
3. Document steps to reproduce
4. Create an issue on GitHub with details

## Development Notes

- **Tabs vs Spaces**: This codebase uses **tabs** for indentation (not the usual 4 spaces)
- **Signal Connections**: Defined in `scenes/main.tscn` connection section
- **Node References**: Use `@onready var` with `$` node paths
- **VRM Loading**: Handled by godot-vrm addon (in `addons/vrm/`)

## File Structure

```
vrmvtube/
├── scenes/
│   └── main.tscn          # Main scene with UI and 3D setup
├── scripts/
│   ├── main.gd            # Main controller
│   ├── webcam_tracker.gd  # Webcam/face tracking
│   ├── face_rigging.gd    # Blend shape application
│   └── camera_controller.gd # Camera controls
├── example/
│   └── cyanmint.vrm       # Example VRM model
├── addons/
│   ├── vrm/               # VRM importer plugin
│   └── Godot-MToon-Shader/ # MToon shader
├── TESTING.md             # Comprehensive testing guide
└── validate.py            # Pre-flight validation script
```

---

Happy testing! 🎉
