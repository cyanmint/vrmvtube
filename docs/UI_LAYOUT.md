# VRMVTube UI Layout

## Main Window Layout

```
+------------------------------------------------------------------+
|                          VRMVTube                                |
+------------------------------------------------------------------+
|  VTuber Application with VRM and MediaPipe Support               |
|  Powered by Godot Engine 4.6                                     |
+------------------------------------------------------------------+
| [Load VRM Model] [Start Tracking]                               |
+------------------------------------------------------------------+
| Status: Ready                                                    |
+------------------------------------------------------------------+
|                                          |                       |
|                                          |   Camera Preview      |
|          3D Viewport                     |   (320x240)          |
|       (VRM Model Display)                |                       |
|                                          |                       |
+------------------------------------------------------------------+
| Control Panel:                                                   |
+------------------------------------------------------------------+
| [Mode: Move]  |  Camera Controls  |  Model Transform            |
|               |                   |                              |
|               | Camera: [Dropdown]| Position:                   |
|               | Position:         |  X: [0.0] Y: [0.0] Z: [0.0] |
|               |  X:[0.0] Y:[1.0]  | Rotation:                   |
|               |  Z:[3.0]          |  X: [0°] Y: [0°] Z: [0°]    |
|               | Rotation:         |                              |
|               |  X:[0°] Y:[0°] Z:[0°]                         |
+------------------------------------------------------------------+

## Interactive Controls

### Mode Button
- Toggles between "Move" and "Rotate" modes
- Move Mode: 
  - Drag viewport: Move camera X/Y
  - Scroll wheel: Move camera Z
- Rotate Mode:
  - Drag viewport: Rotate camera X/Y
  - Scroll wheel: Rotate camera Z

### Camera Controls
- Camera Selector: Dropdown to select available webcams
- Position SpinBoxes: Manually set camera X, Y, Z position
- Rotation SpinBoxes: Manually set camera X, Y, Z rotation (in degrees)

### Model Transform
- Position SpinBoxes: View/set model X, Y, Z position (real-time update)
- Rotation SpinBoxes: View/set model X, Y, Z rotation (real-time update)

## Settings File (user://settings.json)

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

## Features Implemented

1. ✅ Auto-load default VRM model on startup
2. ✅ Settings configuration file (JSON format)
3. ✅ Mode toggle button (Move/Rotate)
4. ✅ Interactive camera control via mouse
   - Drag to move/rotate X/Y
   - Scroll to move/rotate Z
5. ✅ Camera transform UI controls
   - Position spinboxes (X, Y, Z)
   - Rotation spinboxes (X, Y, Z in degrees)
   - Camera selection dropdown
6. ✅ Model transform UI controls
   - Position spinboxes (X, Y, Z)
   - Rotation spinboxes (X, Y, Z in degrees)
   - Real-time display updates
7. ✅ Settings persistence
   - Auto-save on exit
   - Auto-load on startup
