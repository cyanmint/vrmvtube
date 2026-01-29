# VRMVTube UI Mockup

## Main Application Window

This document provides a visual representation of the VRMVTube user interface with all implemented features.

### Window Layout (1280x720)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              VRMVTube                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│           VTuber Application with VRM and MediaPipe Support                 │
│                    Powered by Godot Engine 4.6                              │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│          [ Load VRM Model ]        [ Start Tracking ]                       │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                   Status: VRM model loaded successfully                     │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                             │                               │
│                                             │  ┌─────────────────────────┐ │
│                                             │  │                         │ │
│           ┌──────────────────┐              │  │   Camera Preview        │ │
│           │                  │              │  │                         │ │
│           │                  │              │  │      320 x 240          │ │
│           │   VRM Character  │              │  │                         │ │
│           │                  │              │  │   (Webcam feed)         │ │
│           │   3D Viewport    │              │  │                         │ │
│           │                  │              │  └─────────────────────────┘ │
│           │                  │              │                               │
│           │                  │              │                               │
│           └──────────────────┘              │                               │
│                                             │                               │
│                                             │                               │
├─────────────────────────────────────────────┴───────────────────────────────┤
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │                         Control Panel                                   │ │
│ ├─────────────────────────────────────────────────────────────────────────┤ │
│ │                                                                         │ │
│ │  ┌──────────┐   ┌──────────────────────┐   ┌──────────────────────┐   │ │
│ │  │  Mode:   │   │  Camera Controls     │   │  Model Transform     │   │ │
│ │  │  Move ▼  │   │                      │   │                      │   │ │
│ │  └──────────┘   │ Camera: [Camera 0 ▼] │   │ Position:            │   │ │
│ │                 │                      │   │  X: ┤0.0 ├ Y: ┤0.0 ├ │   │ │
│ │                 │ Position:            │   │  Z: ┤0.0 ├           │   │ │
│ │  Toggle to      │  X: ┤0.0 ├          │   │                      │   │ │
│ │  switch mode    │  Y: ┤1.0 ├          │   │ Rotation:            │   │ │
│ │                 │  Z: ┤3.0 ├          │   │  X: ┤0° ├ Y: ┤0° ├   │   │ │
│ │                 │                      │   │  Z: ┤0° ├            │   │ │
│ │                 │ Rotation:            │   │                      │   │ │
│ │                 │  X: ┤0° ├           │   │  (Real-time update)  │   │ │
│ │                 │  Y: ┤0° ├           │   │                      │   │ │
│ │                 │  Z: ┤0° ├           │   │                      │   │ │
│ │                 └──────────────────────┘   └──────────────────────┘   │ │
│ │                                                                         │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Control Modes

### 🖱️ Move Mode (Default)
When "Mode: Move" is selected:
- **Drag** on 3D viewport → Move camera on X/Y axes
- **Mouse wheel** → Move camera on Z axis (forward/backward)
- All changes reflected immediately in Position spinboxes

### 🔄 Rotate Mode
When "Mode: Rotate" is selected:
- **Drag** on 3D viewport → Rotate camera around X/Y axes
- **Mouse wheel** → Rotate camera around Z axis
- All changes reflected immediately in Rotation spinboxes

## UI Elements

### Mode Toggle Button
```
┌──────────┐
│  Mode:   │ ← Click to toggle between Move and Rotate
│  Move ▼  │
└──────────┘
```

### Camera Controls Panel
```
┌──────────────────────┐
│  Camera Controls     │
│                      │
│ Camera: [Camera 0 ▼] │ ← Select active webcam
│                      │
│ Position:            │
│  X: ┤0.0 ├          │ ← SpinBox: -100 to 100, step 0.1
│  Y: ┤1.0 ├          │ ← SpinBox: -100 to 100, step 0.1
│  Z: ┤3.0 ├          │ ← SpinBox: -100 to 100, step 0.1
│                      │
│ Rotation:            │
│  X: ┤0° ├           │ ← SpinBox: -180 to 180, step 1
│  Y: ┤0° ├           │ ← SpinBox: -180 to 180, step 1
│  Z: ┤0° ├           │ ← SpinBox: -180 to 180, step 1
└──────────────────────┘
```

### Model Transform Panel
```
┌──────────────────────┐
│  Model Transform     │
│                      │
│ Position:            │
│  X: ┤0.0 ├          │ ← SpinBox: -100 to 100, step 0.1
│  Y: ┤0.0 ├          │ ← SpinBox: -100 to 100, step 0.1
│  Z: ┤0.0 ├          │ ← SpinBox: -100 to 100, step 0.1
│                      │
│ Rotation:            │
│  X: ┤0° ├           │ ← SpinBox: -180 to 180, step 1
│  Y: ┤0° ├           │ ← SpinBox: -180 to 180, step 1
│  Z: ┤0° ├           │ ← SpinBox: -180 to 180, step 1
│                      │
│  (Updates in real-time)
└──────────────────────┘
```

## Settings File Structure

The application saves/loads settings from `user://settings.json`:

```json
{
  "model": {
    "default_model_path": "res://assets/models/cyanmint.vrm",
    "auto_load": true,
    "position": {"x": 0.0, "y": 0.0, "z": 0.0},
    "rotation": {"x": 0.0, "y": 0.0, "z": 0.0}
  },
  "camera": {
    "index": 0,
    "position": {"x": 0.0, "y": 1.0, "z": 3.0},
    "rotation": {"x": 0.0, "y": 0.0, "z": 0.0},
    "fov": 75.0
  },
  "tracking": {
    "hand_tracking": true,
    "face_tracking": true
  }
}
```

## Feature Summary

### ✅ Implemented Features

1. **Auto-load Default Model**
   - Automatically loads `cyanmint.vrm` on startup
   - Configurable via settings file

2. **Settings Configuration**
   - JSON-based settings file
   - Persistent storage across sessions
   - Auto-save on application exit

3. **Interactive Camera Control**
   - Two modes: Move and Rotate
   - Mouse drag for X/Y manipulation
   - Mouse wheel/scroll for Z manipulation
   - Real-time visual feedback

4. **Camera Transform UI**
   - 6 SpinBoxes for position (XYZ) and rotation (XYZ)
   - Manual value entry
   - Immediate application of changes
   - Webcam selection dropdown

5. **Model Transform UI**
   - 6 SpinBoxes for position (XYZ) and rotation (XYZ)
   - Real-time display of current values
   - Manual adjustment capability
   - Values update as model moves/rotates

6. **Settings Persistence**
   - Camera position and rotation saved
   - Model position and rotation saved
   - Selected camera index saved
   - All settings restored on next launch

## Usage Instructions

### Loading a VRM Model
1. Click **"Load VRM Model"** button
2. Browse and select a `.vrm` file
3. Model appears in 3D viewport

### Controlling the Camera
**Method 1: Mouse/Trackpad**
1. Click **"Mode: Move"** or **"Mode: Rotate"** to select mode
2. Click and drag on the 3D viewport
3. Use mouse wheel to adjust Z axis

**Method 2: SpinBoxes**
1. Click on any Position or Rotation spinbox
2. Type a value or use arrow buttons
3. Changes apply immediately

### Adjusting the Model
1. Use the Model Transform spinboxes
2. Adjust Position X, Y, Z values
3. Adjust Rotation X, Y, Z values (in degrees)
4. Changes apply and save automatically

### Selecting a Camera
1. Click the Camera dropdown
2. Select from available webcams
3. Selection is saved for next session

## Keyboard Shortcuts (Future Enhancement)
- `M` - Toggle Move/Rotate mode
- `R` - Reset camera to default position
- `Ctrl+O` - Open VRM file dialog
- `F5` - Start/Stop tracking
