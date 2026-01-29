# VRMVTube Settings Popup and VRM Rigging Implementation

## Overview
This document describes the implementation of the settings popup window and VRM face & hand rigging features.

## Changes Made

### 1. Settings Popup Window

**Problem**: The settings panel was always visible, taking up screen space.

**Solution**: Converted the ControlPanel into a popup Window that only appears when the Settings button is clicked.

#### Implementation Details:

- **New UI Element**: Added a "Settings" button to the main button container
- **Window Node**: Converted `ControlPanel` from a `PanelContainer` under `VBoxContainer` to a `Window` node at root level
- **Visibility Control**: The popup window is hidden by default (`visible = false`)
- **Toggle Behavior**: Clicking the Settings button toggles the popup visibility
- **Auto-centering**: When shown, the popup automatically centers on screen

#### Files Modified:
- `scenes/main.tscn`: Restructured UI hierarchy to use Window for settings
- `scripts/main.gd`: Added `settings_popup` reference and `_on_settings_button_pressed()` handler

### 2. VRM Face & Hand Rigging

**Problem**: Face and hand tracking data from MediaPipe was not being applied to the VRM model.

**Solution**: Implemented real-time rigging similar to VRigUnity by mapping MediaPipe data to VRM bones and blendshapes.

#### Face Rigging Implementation:

The `_on_face_blendshapes_updated()` function now:
1. Finds all MeshInstance3D nodes in the loaded VRM model
2. Identifies meshes with blend shapes
3. Maps MediaPipe blendshape data to VRM blend shape indices
4. Applies blend shape values in real-time

```gdscript
func _apply_blendshapes_to_mesh(mesh_instance: MeshInstance3D, blendshapes) -> void:
    # Maps MediaPipe facial expression data to VRM mesh blend shapes
    # Iterates through MediaPipe categories and matches them to VRM blend shape names
    # Applies the score (0.0 to 1.0) to the corresponding blend shape
```

#### Hand Rigging Implementation:

The `_on_hand_landmarks_updated()` function now:
1. Finds the Skeleton3D node in the loaded VRM model
2. Maps MediaPipe hand landmarks to VRM finger bone names
3. Calculates rotations based on landmark positions (placeholder for full implementation)
4. Applies bone transformations in real-time

```gdscript
func _apply_hand_tracking_to_skeleton(skeleton: Skeleton3D, landmarks: Array) -> void:
    # Maps MediaPipe hand landmark data to VRM skeleton finger bones
    # Uses predefined mapping for finger bones:
    # - LeftThumb: landmarks 1-4
    # - LeftIndex: landmarks 5-8
    # - LeftMiddle: landmarks 9-12
    # - LeftRing: landmarks 13-16
    # - LeftLittle: landmarks 17-20
```

#### Helper Functions:

Added utility functions for traversing the VRM model node tree:
- `_find_nodes_by_type()`: Recursively finds all nodes of a specific type
- `_find_node_by_type()`: Finds the first node of a specific type

#### Files Modified:
- `scripts/main.gd`: 
  - Implemented `_on_face_blendshapes_updated()` with actual blendshape application
  - Implemented `_on_hand_landmarks_updated()` for hand tracking
  - Added helper functions for node traversal
  - Connected hand landmarks signal when tracking starts

## Usage

### Opening Settings
1. Launch VRMVTube
2. Click the "Settings" button in the toolbar
3. The settings popup window appears, centered on screen
4. Click "Settings" again or close the window to hide it

### VRM Model Rigging
1. Click "Load VRM Model" to select a VRM file
2. Click "Start Tracking" to enable webcam and MediaPipe tracking
3. Face expressions are automatically applied to the VRM model's blend shapes
4. Hand movements are automatically applied to the VRM model's finger bones

## Technical Details

### Blend Shape Mapping
MediaPipe provides 52 facial blendshapes that are mapped to VRM blend shapes by name matching:
- Uses case-insensitive substring matching
- Examples: "eyeBlinkLeft", "mouthSmileRight", "browInnerUp"

### Hand Landmark Mapping
MediaPipe provides 21 hand landmarks (indices 0-20):
- Wrist: 0
- Thumb: 1-4
- Index: 5-8
- Middle: 9-12
- Ring: 13-16
- Pinky: 17-20

These are mapped to VRM finger bones using standard bone naming conventions.

## Future Improvements

1. **Bone Rotation Calculation**: Implement proper rotation calculation from hand landmark positions
2. **Both Hands Support**: Currently only processes first hand, extend to support both hands
3. **Blend Shape Mapping**: Improve name matching with a configurable mapping dictionary
4. **Performance**: Cache node references to avoid repeated tree traversal
5. **Settings Persistence**: Save/restore popup size and position

## References

- [VRigUnity](https://github.com/Kariaro/VRigUnity): Reference implementation for VRM rigging
- [MediaPipe Face Landmarker](https://developers.google.com/mediapipe/solutions/vision/face_landmarker): 52 facial blendshapes
- [MediaPipe Hand Landmarker](https://developers.google.com/mediapipe/solutions/vision/hand_landmarker): 21 hand landmarks
- [VRM Specification](https://github.com/vrm-c/vrm-specification): VRM model format details
