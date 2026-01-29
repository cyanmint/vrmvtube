# VRMVTube Tools

## MediaPipe Face Tracking Bridge

This directory contains tools for integrating real face tracking with VRMVTube.

### Setup

1. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run VRMVTube** in Godot Engine

3. **Start the MediaPipe bridge:**
   ```bash
   python mediapipe_bridge.py
   ```

4. **Position yourself** in front of your webcam

5. **Watch your VRM avatar** mirror your facial expressions in real-time!

### How It Works

The `mediapipe_bridge.py` script:
- Captures video from your webcam using OpenCV
- Processes each frame with MediaPipe Face Mesh to detect facial landmarks
- Calculates blendshape values (blink, mouth open, head rotation)
- Sends tracking data to VRMVTube via UDP (port 9999)

VRMVTube receives the data and applies it to your VRM avatar in real-time.

### Configuration

Edit `mediapipe_bridge.py` to customize:

- `GODOT_IP` - IP address where VRMVTube is running (default: 127.0.0.1)
- `GODOT_PORT` - UDP port (default: 9999)
- `CAMERA_ID` - Camera device ID (default: 0, use 1 for external webcam)
- `FPS` - Tracking frames per second (default: 30)
- `SHOW_PREVIEW` - Show camera preview window (default: True)

### Troubleshooting

**No tracking data received:**
- Check that VRMVTube is running
- Verify the MediaPipe bridge is running (you should see a preview window)
- Check firewall settings (allow UDP port 9999)

**Poor tracking quality:**
- Ensure good lighting (face should be well-lit)
- Position camera at eye level
- Remove background clutter
- Try adjusting camera settings

**High CPU usage:**
- Reduce FPS in the script
- Lower camera resolution
- Close the preview window (set SHOW_PREVIEW = False)

### System Requirements

- Python 3.8 or newer
- Webcam
- 4GB RAM minimum
- CPU: Intel i5 or equivalent (or better)

### Performance

- CPU Usage: ~10-15% (with preview window)
- Latency: ~30-50ms end-to-end
- FPS: 30 (configurable)

### License

This tool uses:
- MediaPipe (Apache 2.0 License)
- OpenCV (Apache 2.0 License)
- NumPy (BSD License)

All are free for commercial use.
