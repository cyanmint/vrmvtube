# MediaPipe Model Files

This directory contains MediaPipe model files required for face and hand tracking.

## Required Files

### Hand Landmarker Model
- **File**: `hand_landmarker.task`
- **Size**: ~11 MB
- **Download**: https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task
- **Description**: MediaPipe Hand Landmarker model for detecting and tracking 21 hand landmarks in real-time

### Face Landmarker Model
- **File**: `face_landmarker.task`
- **Size**: ~10 MB  
- **Download**: https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/latest/face_landmarker.task
- **Description**: MediaPipe Face Landmarker model for detecting 478 face landmarks and 52 blendshapes

## Installation Instructions

1. Download the model files from the links above
2. Place them in this directory (`assets/models/mediapipe/`)
3. Ensure the files are named exactly:
   - `hand_landmarker.task`
   - `face_landmarker.task`
4. The files will be automatically loaded when tracking is started

## Alternative: Automatic Download Script

You can use this bash script to download the files automatically:

```bash
#!/bin/bash
cd assets/models/mediapipe

# Download hand landmarker model
echo "Downloading hand landmarker model..."
curl -L -o hand_landmarker.task https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task

# Download face landmarker model
echo "Downloading face landmarker model..."
curl -L -o face_landmarker.task https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/latest/face_landmarker.task

echo "Download complete!"
```

## Model Information

These models are developed and provided by Google MediaPipe team:
- License: Apache 2.0
- Documentation: https://developers.google.com/mediapipe/solutions/vision/hand_landmarker
- Documentation: https://developers.google.com/mediapipe/solutions/vision/face_landmarker

## Troubleshooting

If tracking doesn't work:
1. Verify model files exist in this directory
2. Check file names are exactly correct (case-sensitive)
3. Ensure files are not corrupted (check file sizes match)
4. Check console for error messages from tracking managers
5. Verify GDMP plugin is enabled in Project Settings > Plugins
