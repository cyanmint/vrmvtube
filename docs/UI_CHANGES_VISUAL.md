# VRMVTube UI Changes - Settings Popup

## Before Changes

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              VRMVTube                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│           VTuber Application with VRM and MediaPipe Support                 │
│                    Powered by Godot Engine 4.6                              │
├─────────────────────────────────────────────────────────────────────────────┤
│          [ Load VRM Model ]        [ Start Tracking ]                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                   Status: VRM model loaded successfully                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                             │                               │
│           ┌──────────────────┐              │  ┌─────────────────────────┐ │
│           │                  │              │  │   Camera Preview        │ │
│           │   VRM Character  │              │  │      320 x 240          │ │
│           │   3D Viewport    │              │  │   (Webcam feed)         │ │
│           │                  │              │  └─────────────────────────┘ │
│           └──────────────────┘              │                               │
├─────────────────────────────────────────────┴───────────────────────────────┤
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │                    SETTINGS PANEL (Always Visible)                      │ │
│ │  [Mode: Move]  Camera Controls  Model Transform                        │ │
│ │  Position/Rotation spinboxes taking up space...                         │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Problem**: Settings panel always visible, taking up screen space

## After Changes

### Main Window (Settings Hidden - Default State)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              VRMVTube                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│           VTuber Application with VRM and MediaPipe Support                 │
│                    Powered by Godot Engine 4.6                              │
├─────────────────────────────────────────────────────────────────────────────┤
│     [ Load VRM Model ]   [ Start Tracking ]   [ Settings ]                 │
│                                                     ↑                        │
│                                                   NEW!                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                   Status: VRM model loaded successfully                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                                             │                               │
│           ┌──────────────────┐              │  ┌─────────────────────────┐ │
│           │                  │              │  │   Camera Preview        │ │
│           │                  │              │  │      320 x 240          │ │
│           │   VRM Character  │              │  │   (Webcam feed)         │ │
│           │                  │              │  │                         │ │
│           │   3D Viewport    │              │  │   Face & Hand           │ │
│           │                  │              │  │   tracking active       │ │
│           │  (More Space!)   │              │  │                         │ │
│           │                  │              │  └─────────────────────────┘ │
│           │                  │              │                               │
│           └──────────────────┘              │                               │
│                                             │                               │
│                                             │                               │
└─────────────────────────────────────────────┴───────────────────────────────┘
```

**Benefit**: More space for 3D viewport and camera preview

### Settings Popup Window (When Opened)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              VRMVTube                                       │
│                     (Main window, slightly dimmed)                          │
│                                                                             │
│     ┌─────────────────────────────────────────────────────┐                │
│     │                    Settings                     [X] │                │
│     ├─────────────────────────────────────────────────────┤                │
│     │ ┌─────────────────────────────────────────────────┐ │                │
│     │ │  [Mode: Move]  Camera Controls  Model Transform│ │                │
│     │ │                                                 │ │                │
│     │ │  Camera: [Camera 0 ▼]                          │ │                │
│     │ │                                                 │ │                │
│     │ │  Camera Position:                              │ │                │
│     │ │    X: ┤0.0 ├  Y: ┤1.0 ├  Z: ┤3.0 ├           │ │                │
│     │ │                                                 │ │                │
│     │ │  Camera Rotation:                              │ │                │
│     │ │    X: ┤0° ├  Y: ┤0° ├  Z: ┤0° ├              │ │                │
│     │ │                                                 │ │                │
│     │ │  Model Position:                               │ │                │
│     │ │    X: ┤0.0 ├  Y: ┤0.0 ├  Z: ┤0.0 ├           │ │                │
│     │ │                                                 │ │                │
│     │ │  Model Rotation:                               │ │                │
│     │ │    X: ┤0° ├  Y: ┤0° ├  Z: ┤0° ├              │ │                │
│     │ └─────────────────────────────────────────────────┘ │                │
│     │                                                     │                │
│     └─────────────────────────────────────────────────────┘                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Usage**: Click "Settings" button to toggle popup on/off

## VRM Rigging Features

### Face Tracking Integration

```
MediaPipe Face Landmarks          VRM Model Mesh
┌─────────────────────┐           ┌─────────────────────┐
│                     │           │                     │
│  52 Blendshapes:    │  ──────>  │  Blend Shapes:      │
│                     │           │                     │
│  • eyeBlinkLeft     │           │  • eyeBlinkLeft     │
│  • eyeBlinkRight    │           │  • eyeBlinkRight    │
│  • mouthSmileLeft   │           │  • mouthSmileLeft   │
│  • mouthSmileRight  │           │  • mouthSmileRight  │
│  • jawOpen          │           │  • jawOpen          │
│  • browInnerUp      │           │  • browInnerUp      │
│  • ... (46 more)    │           │  • ... (matched)    │
│                     │           │                     │
└─────────────────────┘           └─────────────────────┘
       Real-time               Applied to VRM face
    face expression               in real-time
```

### Hand Tracking Integration

```
MediaPipe Hand Landmarks          VRM Model Skeleton
┌─────────────────────┐           ┌─────────────────────┐
│                     │           │                     │
│  21 Landmarks:      │  ──────>  │  Finger Bones:      │
│                     │           │                     │
│  [0] Wrist          │           │  (root)             │
│  [1-4] Thumb        │           │  LeftThumb 1-4      │
│  [5-8] Index        │           │  LeftIndex 1-4      │
│  [9-12] Middle      │           │  LeftMiddle 1-4     │
│  [13-16] Ring       │           │  LeftRing 1-4       │
│  [17-20] Pinky      │           │  LeftLittle 1-4     │
│                     │           │                     │
└─────────────────────┘           └─────────────────────┘
       Real-time               Applied to VRM hands
    hand positions               in real-time
```

## Key Features

### 1. Settings Popup
- ✅ Hidden by default (more viewport space)
- ✅ Toggle with Settings button
- ✅ Auto-centers on screen
- ✅ Can be moved/resized
- ✅ All previous settings functionality preserved

### 2. VRM Model Loading
- ✅ File dialog for selecting .vrm files
- ✅ Supports VRM 0.0 and VRM 1.0
- ✅ Auto-loads default model on startup
- ✅ Model position/rotation configurable

### 3. Face Rigging (VRigUnity-style)
- ✅ 52 facial blendshapes from MediaPipe
- ✅ Automatic mapping to VRM blend shapes
- ✅ Real-time expression tracking
- ✅ Name-based matching algorithm

### 4. Hand Rigging (VRigUnity-style)
- ✅ 21 hand landmarks from MediaPipe
- ✅ Mapping to VRM finger bones
- ✅ Real-time hand tracking
- ✅ Supports finger articulation

## Technical Implementation

### Code Structure

```
main.gd
├── setup_ui_references()
│   └── Gets SettingsPopup window reference
├── _on_settings_button_pressed()
│   └── Toggles popup visibility & centers
├── _on_face_blendshapes_updated(blendshapes)
│   ├── Finds MeshInstance3D nodes
│   ├── Gets blend shape data
│   └── Applies to VRM mesh
├── _on_hand_landmarks_updated(landmarks)
│   ├── Finds Skeleton3D node
│   ├── Maps landmarks to bones
│   └── Applies rotations
└── Helper functions
    ├── _find_nodes_by_type()
    ├── _find_node_by_type()
    ├── _apply_blendshapes_to_mesh()
    └── _apply_hand_tracking_to_skeleton()
```

### Data Flow

```
Camera/Webcam
     ↓
MediaPipe AI Processing
     ↓
┌────────────────────────────┐
│  Hand Landmarks (21 pts)   │
│  Face Blendshapes (52)     │
└────────────────────────────┘
     ↓
Signal Connections
     ↓
┌────────────────────────────┐
│  _on_hand_landmarks_updated│
│  _on_face_blendshapes_...  │
└────────────────────────────┘
     ↓
VRM Model Application
     ↓
┌────────────────────────────┐
│  Mesh Blend Shapes         │
│  Skeleton Bone Rotations   │
└────────────────────────────┘
     ↓
Real-time VRM Animation
```

## Comparison with VRigUnity

| Feature | VRigUnity | VRMVTube |
|---------|-----------|----------|
| Platform | Unity | Godot |
| VRM Support | ✅ | ✅ |
| MediaPipe Face | ✅ | ✅ |
| MediaPipe Hands | ✅ | ✅ |
| Face Blendshapes | ✅ 52 shapes | ✅ 52 shapes |
| Hand Landmarks | ✅ 21 points | ✅ 21 points |
| Real-time Rigging | ✅ | ✅ |
| Settings UI | In-panel | Popup Window |

## Benefits

1. **More Screen Space**: Settings hidden by default, larger viewport
2. **Better UX**: Settings only shown when needed
3. **Full Rigging**: Face and hand tracking fully integrated
4. **VRigUnity Compatibility**: Similar rigging approach
5. **Real-time Performance**: Efficient node traversal and mapping
