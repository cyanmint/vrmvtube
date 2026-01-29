# VRMVTube Testing Guide

This document describes how to test the core features of VRMVTube.

## Prerequisites

- Godot 4.3 or newer installed
- A webcam (for face tracking tests)
- A VRM model file (.vrm format)

## Core Features to Test

### 1. Model Viewing and Positioning

**Test Steps:**
1. Open the project in Godot 4.3+
2. Run the main scene (`scenes/main.tscn` or press F5)
3. The app should automatically load the example VRM model (`example/cyanmint.vrm`)

**Expected Results:**
- VRM model should be visible in the 3D viewport
- Model should be centered at origin (0, 0, 0)
- Model should be properly lit by the directional light

**Camera Controls:**
- **Drag with mouse**: Rotate camera around model
- **Shift + Drag**: Pan camera (move left/right/up/down)
- **Mouse wheel**: Zoom in/out
- Camera should move smoothly and maintain focus on model

**Model Controls:**
Test the model transformation controls in the bottom panel:
- **Position Y Slider**: Move model up/down (-2.0 to 2.0)
  - Slider should update the label value
  - Model should move vertically in real-time
- **Scale Slider**: Scale model (0.5x to 2.0x)
  - Slider should update the label value
  - Model should scale uniformly in real-time
- **Reset Pose Button**: Reset model to default position and scale
  - Model should return to position (0, 0, 0)
  - Scale should return to 1.0
  - Sliders should reset to default values

### 2. Face Motion Capture via Webcam

**Test Steps:**
1. Ensure you have a webcam connected
2. Run the project
3. Grant webcam permissions when prompted (browser/OS may ask)

**Expected Results:**

**Webcam Preview Panel (top-right):**
- Should display "Webcam Preview" label
- Should show live camera feed in the preview window
- Status label should show "Tracking Active"

**Console Output:**
```
WebcamTracker: Initializing for platform: [Your Platform]
WebcamTracker: Found N camera feed(s)
WebcamTracker: Using camera: [Camera Name]
WebcamTracker: Camera activated
WebcamTracker: Face tracking started
Main: Webcam is available and tracking is active
```

**If No Webcam:**
- Preview status should show "No Webcam"
- Info label should indicate "No webcam found"
- Console should show warning about webcam unavailability

**Tracking Data Flow:**
- Even without actual face detection, the system should emit simulated tracking data
- The FaceRigging component should receive this data via signals
- No errors should appear in the console related to signal connections

### 3. Face Rigging

**Test Steps:**
1. Load a VRM model (use the example or load your own)
2. Ensure webcam tracking is active
3. Observe the model's face

**Expected Results:**

**Simulated Tracking (current implementation):**
Since actual face detection is not yet implemented, the system uses simulated data:
- Model should show **subtle blinking** (eyes close periodically)
- Model should show **slight mouth movement** (mouth opens/closes gently)
- Model's **head should rotate** slightly (subtle left-right and up-down movement)
- All movements should be **smooth** due to interpolation

**FaceRigging Debug Output:**
When a model is loaded, check the console for:
```
FaceRigging: VRM model set
FaceRigging: Mesh has N blend shapes
  - [List of available blend shapes]
```

**Blend Shape Mapping:**
The system attempts to map tracking data to VRM blend shapes:
- `blink_left` → "blinkLeft" blend shape
- `blink_right` → "blinkRight" blend shape
- `mouth_open` → "aa" blend shape
- `smile` → "joy" blend shape
- `head_rotation` → Head bone rotation

**Common Issues:**
- If no blend shapes are detected: VRM model may not have standard blend shapes
- If no movement: Check that signals are connected (see scene file connections)
- Jerky movement: Adjust `smoothing_factor` in FaceRigging script (default: 0.3)

### 4. Integration Testing

**Complete Pipeline Test:**
1. Start the application
2. Verify webcam initializes (check preview panel and console)
3. Verify model loads (should see model in 3D view)
4. Verify tracking data flows:
   - WebcamTracker emits `face_tracking_updated` signal
   - FaceRigging receives signal and calls `apply_tracking_data()`
   - Model blend shapes and bones are updated
5. Test UI controls:
   - Load a different VRM model via "Load VRM Model" button
   - Adjust model position and scale
   - Reset model pose
6. Test camera controls (rotate, pan, zoom)

## Platform-Specific Tests

### Windows
- Virtual camera support: Supported (feature not yet implemented)
- Webcam access: Should work with DirectShow/MediaFoundation

### Linux
- Virtual camera support: Supported (feature not yet implemented)
- Webcam access: Should work with V4L2

### macOS
- Virtual camera: Not supported (platform limitation)
- Webcam access: Should work via AVFoundation

### Web (Browser)
- Webcam access: Requires HTTPS and user permission
- May need to grant camera permissions in browser settings

## Troubleshooting

### Webcam Not Detected
- Check if camera is connected and working in other apps
- Check OS/browser permissions
- Look for console errors starting with "WebcamTracker:"

### Model Not Loading
- Verify VRM file is valid (test in VRoid Studio or similar)
- Check file path is correct
- Look for console errors starting with "Main:" or "Error:"

### No Face Animation
- Verify tracking is active (check webcam preview status)
- Check console for FaceRigging messages
- Verify model has blend shapes (check debug output)
- Ensure signals are connected (check scenes/main.tscn connections section)

### Performance Issues
- Close other applications using the webcam
- Try reducing window size
- Check system resource usage

## Future Testing (Not Yet Implemented)

These features are planned but not yet implemented:

- **Real Face Tracking**: Using MediaPipe or OpenCV for actual face landmark detection
- **Hand Tracking**: Detecting and tracking hand movements
- **Virtual Camera**: Output to virtual camera device
- **VMC Protocol**: Network-based motion capture protocol
- **Recording/Playback**: Save and replay tracking sessions

## Automated Testing

Currently, there are no automated tests. To add tests:
1. Create a `tests/` directory
2. Write GDScript unit tests using Godot's testing framework
3. Test individual components (WebcamTracker, FaceRigging, CameraController)

## Reporting Issues

When reporting issues, please include:
- Godot version
- Operating system and version
- VRM model used (if issue is model-specific)
- Console output (especially errors and warnings)
- Steps to reproduce
- Expected vs actual behavior
