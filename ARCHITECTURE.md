# VRMVTube Architecture

This document describes the architecture and data flow of VRMVTube.

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                       VRMVTube Application                  │
│                     (Godot 4.3+ Project)                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────┐      ┌──────────────┐      ┌──────────────┐
│   Webcam    │─────▶│ WebcamTracker│─────▶│ FaceRigging  │
│   (Input)   │      │  (Tracking)  │      │  (Rigging)   │
└─────────────┘      └──────────────┘      └──────────────┘
                              │                     │
                              ▼                     ▼
                     ┌────────────────┐    ┌──────────────┐
                     │ Webcam Preview │    │  VRM Model   │
                     │   (UI Panel)   │    │ (3D Object)  │
                     └────────────────┘    └──────────────┘
                                                    │
                                                    ▼
                                           ┌──────────────┐
                                           │   Camera3D   │
                                           │  (Viewport)  │
                                           └──────────────┘
                                                    │
                                                    ▼
                                           ┌──────────────┐
                                           │   Display    │
                                           └──────────────┘
```

## Component Details

### 1. Main Scene (`scenes/main.tscn`)

**Node Hierarchy:**
```
Main (Node3D)
├── ModelContainer (Node3D)
│   └── [VRM Model Instance] (loaded at runtime)
├── Camera3D (with camera_controller.gd)
├── DirectionalLight3D
├── WorldEnvironment
├── UI (CanvasLayer)
│   ├── Title, Buttons, Info
│   ├── WebcamPreviewPanel
│   └── ModelControlsPanel
├── FileDialog
├── WebcamTracker (Node with webcam_tracker.gd)
└── FaceRigging (Node with face_rigging.gd)
```

### 2. WebcamTracker (`scripts/webcam_tracker.gd`)

**Responsibilities:**
- Initialize webcam using Godot's CameraServer
- Capture camera frames
- Generate tracking data (currently simulated)
- Emit `face_tracking_updated` signal

**Data Flow:**
```
Webcam → CameraServer → CameraFeed → CameraTexture
                             ↓
                     Process Frames
                             ↓
                  Generate Tracking Data
                             ↓
                Emit face_tracking_updated Signal
```

**Tracking Data Structure:**
```gdscript
{
    "head_rotation": Vector3(x, y, z),    # Euler angles in radians
    "head_position": Vector3(x, y, z),    # World position offset
    "blink_left": float (0.0 to 1.0),     # Left eye closure
    "blink_right": float (0.0 to 1.0),    # Right eye closure
    "mouth_open": float (0.0 to 1.0),     # Mouth openness
    "smile": float (0.0 to 1.0),          # Smile intensity
    "tracking_quality": float (0.0 to 1.0) # Tracking confidence
}
```

### 3. FaceRigging (`scripts/face_rigging.gd`)

**Responsibilities:**
- Receive tracking data from WebcamTracker
- Map tracking data to VRM blend shapes
- Apply smooth interpolation
- Update VRM model bones and blend shapes

**Blend Shape Mapping:**
```
Tracking Data        →  VRM Blend Shape
──────────────────────────────────────────
blink_left          →  blinkLeft
blink_right         →  blinkRight
mouth_open          →  aa (mouth open)
smile               →  joy (happy)
head_rotation       →  Head bone rotation
```

**Processing Pipeline:**
```
1. Receive tracking_data from signal
2. Update target blend shape values
3. Each frame (_process):
   a. Smooth current → target (lerp)
   b. Find mesh with blend shapes
   c. Apply blend shape values
   d. Find skeleton
   e. Apply head rotation to head bone
```

### 4. CameraController (`scripts/camera_controller.gd`)

**Responsibilities:**
- Handle mouse input for camera control
- Rotate camera around model (orbit)
- Pan camera (translate)
- Zoom camera (distance)

**Controls:**
```
Left-click + Drag    → Rotate (orbit around model)
Shift + Drag         → Pan (move camera)
Mouse Wheel          → Zoom (change distance)
```

**Camera Math:**
```
Position = Target + Offset * Distance

Offset.x = cos(rotation.y) * sin(rotation.x)
Offset.y = sin(rotation.y)
Offset.z = cos(rotation.y) * cos(rotation.x)
```

### 5. Main Controller (`scripts/main.gd`)

**Responsibilities:**
- Initialize the application
- Load VRM models
- Connect signals between components
- Handle UI interactions
- Manage model transformations

**Initialization Flow:**
```
1. _ready():
   a. Display platform info
   b. Connect webcam signals
   c. Load default VRM model
   d. Connect UI controls

2. Load VRM Model:
   a. Load .vrm file as PackedScene
   b. Instantiate scene
   c. Add to ModelContainer
   d. Connect to FaceRigging

3. UI Updates:
   a. Update info labels
   b. Update webcam preview
   c. Update model controls
```

## Signal Flow

```
┌──────────────────┐
│  WebcamTracker   │
└────────┬─────────┘
         │ face_tracking_updated(tracking_data: Dictionary)
         ▼
┌──────────────────┐
│   FaceRigging    │
│ apply_tracking_  │
│  data()          │
└────────┬─────────┘
         │ (updates VRM blend shapes)
         ▼
┌──────────────────┐
│   VRM Model      │
│  (blend shapes)  │
└──────────────────┘

┌──────────────────┐
│  UI Buttons      │
└────────┬─────────┘
         │ pressed signals
         ▼
┌──────────────────┐
│  Main Controller │
│  (handlers)      │
└──────────────────┘
```

## Data Flow Timeline

```
Time 0: Application Start
├─ Initialize WebcamTracker
├─ Initialize FaceRigging
├─ Load default VRM model
└─ Connect signals

Time 1: Webcam Available
├─ WebcamTracker detects camera
├─ Activate camera feed
├─ Start tracking
└─ Update UI (preview panel)

Time 2-∞: Runtime Loop (every frame)
├─ WebcamTracker:
│  ├─ Generate tracking data
│  └─ Emit face_tracking_updated signal
├─ FaceRigging:
│  ├─ Receive tracking data
│  ├─ Update target blend shapes
│  ├─ Lerp current → target (smooth)
│  └─ Apply to VRM model
├─ CameraController:
│  ├─ Handle mouse input
│  └─ Update camera transform
└─ Render frame
```

## File Organization

```
vrmvtube/
├── scenes/
│   └── main.tscn              # Main scene (UI + 3D setup)
├── scripts/
│   ├── main.gd                # Main controller
│   ├── webcam_tracker.gd      # Webcam/tracking logic
│   ├── face_rigging.gd        # Blend shape application
│   └── camera_controller.gd   # Camera controls
├── addons/
│   ├── vrm/                   # VRM importer (godot-vrm)
│   └── Godot-MToon-Shader/    # MToon shader for VRM
├── example/
│   └── cyanmint.vrm           # Example VRM model
└── models/                    # User VRM models (gitignored)
```

## Future Architecture (Real Face Tracking)

When real face tracking is implemented, the architecture will change:

```
┌─────────────┐      ┌──────────────┐      ┌──────────────┐
│   Webcam    │─────▶│ Face Detector│─────▶│ FaceRigging  │
│   (Input)   │      │  (MediaPipe/ │      │  (Rigging)   │
│             │      │   OpenCV)    │      │              │
└─────────────┘      └──────────────┘      └──────────────┘
                              │                     │
                     Extract Landmarks        Map to VRM
                     (478 points)            Blend Shapes
```

**Required Changes:**
1. Add MediaPipe or OpenCV integration
2. Process camera frames for face landmarks
3. Map 478 facial landmarks to VRM expressions
4. Improve tracking accuracy and performance

## Performance Considerations

### Current Performance:
- **VRM Loading**: ~2-5 seconds (depends on model complexity)
- **Webcam Init**: ~1-2 seconds
- **Frame Rate**: 30-60 FPS (depends on model)
- **Tracking Update**: Every frame (~33ms @ 30 FPS)

### Bottlenecks:
1. VRM model complexity (polygons, blend shapes)
2. Webcam resolution and frame rate
3. Future: Real-time face detection CPU usage

### Optimizations:
1. Use lower resolution for face tracking
2. Reduce tracking update rate if needed
3. LOD (Level of Detail) for complex models
4. Async face detection in separate thread

## Cross-Platform Considerations

### Desktop (Windows, macOS, Linux):
- Full feature support
- High-resolution webcam
- Better performance
- Virtual camera (Windows/Linux only)

### Mobile (Android):
- Webcam via front/back camera
- Touch controls needed (future)
- Lower resolution recommended
- Battery optimization needed

### Web:
- Webcam via browser API
- HTTPS required for camera access
- User permission prompt
- Limited performance

## Security & Privacy

### Webcam Access:
- Always request user permission
- Show camera preview (transparency)
- Allow disabling tracking
- No data uploaded/stored

### VRM Models:
- Validate file before loading
- Handle corrupted files gracefully
- Respect model licenses
- No telemetry or tracking

---

## References

- Godot Documentation: https://docs.godotengine.org/
- godot-vrm: https://github.com/V-Sekai/godot-vrm
- VRM Specification: https://vrm.dev/
- MediaPipe: https://mediapipe.dev/
