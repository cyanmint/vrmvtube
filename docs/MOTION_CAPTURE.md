# Motion Capture Integration Guide

## Overview

VRMVTube currently uses simulated face tracking data. For real face tracking and motion capture, you can integrate one of the following solutions with Godot 4.

## Recommended Motion Capture Libraries

### 1. MediaPipe (Recommended)

**Google's MediaPipe** is the industry-standard solution for real-time face, hand, and pose tracking using webcams.

#### Features
- Cross-platform (Windows, macOS, Linux, Web, Mobile)
- Real-time face mesh with 468 landmarks
- Face blendshapes (52 expressions compatible with VRM)
- High performance and accuracy
- Free and open-source

#### Integration Methods

##### Option A: PipeDoll Addon (Easiest)
[PipeDoll](https://github.com/ectucker1/pipedoll) is a motion capture addon for Godot that uses MediaPipe.

**Installation:**
1. Download PipeDoll from GitHub
2. Extract to your project folder
3. Enable the addon in Project Settings → Plugins
4. Configure MediaPipe models in the addon settings

**Pros:**
- Native Godot integration
- Easy setup
- Good documentation

**Cons:**
- Primarily focused on 2D motion capture
- May need modifications for 3D VRM avatars

##### Option B: Python Bridge (Most Flexible)
Run MediaPipe in Python and send data to Godot via UDP/WebSocket.

**Setup:**
1. Install Python dependencies:
   ```bash
   pip install mediapipe opencv-python
   ```

2. Create Python script for face tracking:
   ```python
   import cv2
   import mediapipe as mp
   import socket
   import json
   
   mp_face_mesh = mp.solutions.face_mesh
   face_mesh = mp_face_mesh.FaceMesh(
       max_num_faces=1,
       refine_landmarks=True,
       min_detection_confidence=0.5,
       min_tracking_confidence=0.5
   )
   
   # Setup UDP socket
   sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
   GODOT_IP = "127.0.0.1"
   GODOT_PORT = 9999
   
   cap = cv2.VideoCapture(0)
   
   while cap.isOpened():
       success, image = cap.read()
       if not success:
           continue
       
       # Process image with MediaPipe
       image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
       results = face_mesh.process(image_rgb)
       
       if results.multi_face_landmarks:
           landmarks = results.multi_face_landmarks[0]
           
           # Extract blendshapes/landmarks
           data = {
               "blink_left": calculate_blink(landmarks, "left"),
               "blink_right": calculate_blink(landmarks, "right"),
               "mouth_open": calculate_mouth_open(landmarks),
               "head_rotation": calculate_head_rotation(landmarks)
           }
           
           # Send to Godot
           sock.sendto(json.dumps(data).encode(), (GODOT_IP, GODOT_PORT))
   ```

3. In Godot, create a UDP listener:
   ```gdscript
   extends Node
   
   var udp := PacketPeerUDP.new()
   
   func _ready():
       udp.bind(9999)
   
   func _process(delta):
       if udp.get_available_packet_count() > 0:
           var packet = udp.get_packet()
           var data = JSON.parse_string(packet.get_string_from_utf8())
           face_tracking_updated.emit(data)
   ```

**Pros:**
- Full access to MediaPipe's features
- Easy to customize
- Can use all 52 face blendshapes
- Better performance control

**Cons:**
- Requires Python installation
- More complex setup
- Need to manage external process

##### Option C: GDExtension (Advanced)
Create a native GDExtension that wraps MediaPipe.

**Pros:**
- Best performance
- Native Godot integration
- No external dependencies at runtime

**Cons:**
- Requires C++ knowledge
- Complex to build and maintain
- Platform-specific compilation

**Reference Projects:**
- [vdot](https://github.com/northernpaws/vdot) - VTubing program with GDExtension tracking

### 2. SnekStudio

[SnekStudio](https://snekstudio.com/) is a free, open-source VTuber software built in Godot 4 that uses MediaPipe.

**Features:**
- 50+ facial blendshapes
- VRM avatar support
- Hand tracking
- Open-source code you can study/adapt

**Use Cases:**
- Reference implementation for face tracking
- Fork and modify for your needs
- Study their MediaPipe integration

### 3. iPhone Face Tracking (Live Link Face)

For iOS users, iPhone's TrueDepth camera provides high-quality face tracking.

**Setup:**
1. Install Live Link Face app on iPhone
2. Configure to send data over network
3. Create a Godot script to receive Live Link Face UDP packets
4. Map ARKit blendshapes to VRM blendshapes

**Pros:**
- Highest quality face tracking
- Low latency
- 52 ARKit blendshapes

**Cons:**
- Requires iPhone X or newer
- Only works on iOS
- Requires app purchase (~$3)

### 4. OpenCV + Dlib

Traditional computer vision approach using OpenCV and Dlib.

**Features:**
- Face landmark detection (68 points)
- Eye tracking
- Mouth tracking
- Head pose estimation

**Pros:**
- Mature and stable
- Good documentation
- Works on any platform

**Cons:**
- Less accurate than MediaPipe
- Fewer facial features
- Requires more manual calibration

**Setup:**
```bash
pip install opencv-python dlib
```

## Integration into VRMVTube

### Step 1: Choose Your Method

For most users, we recommend:
- **Beginners**: Start with simulated tracking (current implementation)
- **Intermediate**: Use Python + MediaPipe bridge (Option B)
- **Advanced**: Fork SnekStudio or use PipeDoll

### Step 2: Modify webcam_tracker.gd

Replace the simulated tracking in `_update_simulated_tracking()` with real data:

```gdscript
# Replace simulated tracking with real data
func _update_tracking_from_mediapipe(data: Dictionary) -> void:
    """Update tracking from MediaPipe data"""
    
    # Map MediaPipe blendshapes to our tracking format
    blink_left = data.get("eyeBlinkLeft", 0.0)
    blink_right = data.get("eyeBlinkRight", 0.0)
    mouth_open = data.get("jawOpen", 0.0)
    smile = data.get("mouthSmile", 0.0)
    
    # Head rotation from pose
    if data.has("head_rotation"):
        head_rotation = data["head_rotation"]
    
    # Emit tracking data
    var tracking_data := {
        "head_rotation": head_rotation,
        "head_position": head_position,
        "blink_left": blink_left,
        "blink_right": blink_right,
        "mouth_open": mouth_open,
        "smile": smile,
        "tracking_quality": 1.0
    }
    
    face_tracking_updated.emit(tracking_data)
```

### Step 3: Add UDP Receiver

Create a new script `mediapipe_receiver.gd`:

```gdscript
extends Node

signal tracking_data_received(data: Dictionary)

var udp := PacketPeerUDP.new()
const PORT := 9999

func _ready() -> void:
    var err := udp.bind(PORT)
    if err != OK:
        push_error("Failed to bind UDP port %d" % PORT)
    else:
        print("MediaPipe receiver listening on port %d" % PORT)

func _process(_delta: float) -> void:
    while udp.get_available_packet_count() > 0:
        var packet := udp.get_packet()
        var json_str := packet.get_string_from_utf8()
        var data = JSON.parse_string(json_str)
        
        if data != null:
            tracking_data_received.emit(data)
```

### Step 4: Connect to WebcamTracker

In `main.gd`, add the receiver and connect it:

```gdscript
@onready var mediapipe_receiver: Node = $MediaPipeReceiver

func _ready() -> void:
    # ... existing code ...
    
    if mediapipe_receiver:
        mediapipe_receiver.tracking_data_received.connect(_on_mediapipe_data)

func _on_mediapipe_data(data: Dictionary) -> void:
    """Handle MediaPipe tracking data"""
    if webcam_tracker:
        webcam_tracker._update_tracking_from_mediapipe(data)
```

## MediaPipe Blendshape Mapping

MediaPipe provides 52 blendshapes that map well to VRM expressions:

| MediaPipe Blendshape | VRM Expression | Description |
|---------------------|----------------|-------------|
| eyeBlinkLeft | blinkLeft | Left eye blink |
| eyeBlinkRight | blinkRight | Right eye blink |
| jawOpen | aa | Mouth open |
| mouthSmile | joy | Smile |
| mouthFrown | sorrow | Sad expression |
| browDownLeft | angry | Angry (left) |
| browDownRight | angry | Angry (right) |
| eyeWideLeft | surprised | Surprised |
| eyeWideRight | surprised | Surprised |

Full list: [MediaPipe Face Blendshapes](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker)

## Performance Considerations

### CPU Usage
- MediaPipe: ~10-15% CPU (Python)
- MediaPipe GDExtension: ~5-8% CPU
- Godot rendering: ~15-20% CPU
- **Total**: ~30-35% CPU for real-time tracking

### Latency
- Python bridge: ~30-50ms
- GDExtension: ~10-20ms
- iPhone Live Link: ~20-30ms

### Optimization Tips
1. Reduce camera resolution (480p is sufficient)
2. Limit tracking FPS to 30 (matches display)
3. Use face detection sparingly (once per second)
4. Smooth tracking data with exponential moving average

## Testing Your Integration

1. **Start Python script** (if using Python bridge)
2. **Launch VRMVTube** 
3. **Check console** for connection messages
4. **Look at webcam HUD** - should show real tracking values
5. **Move your face** - avatar should mirror expressions
6. **Test blinking** - eyes should close
7. **Open mouth** - avatar mouth should open

## Troubleshooting

### No tracking data received
- Check Python script is running
- Verify port 9999 is not blocked by firewall
- Check IP address (use 127.0.0.1 for local)

### Poor tracking quality
- Improve lighting (face should be well-lit)
- Position camera at eye level
- Ensure face is clearly visible
- Reduce background clutter

### High CPU usage
- Lower camera resolution
- Reduce tracking FPS
- Use face detection less frequently

## Future Improvements

- [ ] Auto-calibration system
- [ ] Multi-face tracking support
- [ ] Recording and playback
- [ ] Custom blendshape mapping editor
- [ ] Performance profiling tools

## Resources

### Documentation
- [MediaPipe Face Landmarker](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker)
- [MediaPipe Python API](https://google.github.io/mediapipe/solutions/face_mesh.html)
- [Godot UDP Networking](https://docs.godotengine.org/en/stable/classes/class_packetpeerudp.html)

### Example Projects
- [PipeDoll](https://github.com/ectucker1/pipedoll) - Godot MediaPipe addon
- [SnekStudio](https://snekstudio.com/) - Full VTuber solution
- [vdot](https://github.com/northernpaws/vdot) - GDExtension VTubing
- [godot-python-comm](https://github.com/trflorian/godot-python-comm) - Python-Godot bridge

### Video Tutorials
- [Face Check - Godot 4 Face Tracking](https://www.youtube.com/watch?v=yL3K0VPU75A)
- [MediaPipe Face Mesh Tutorial](https://dev.to/trish-xd/ai-face-body-and-hand-pose-detection-with-python-and-mediapipe-4p5)

## License Considerations

- **MediaPipe**: Apache 2.0 License (commercial use allowed)
- **OpenCV**: Apache 2.0 License (commercial use allowed)
- **Dlib**: Boost Software License (commercial use allowed)

All recommended libraries are free for commercial use.

---

**Next Steps:** Choose your integration method and follow the setup guide above. For questions or help, open an issue on GitHub.
