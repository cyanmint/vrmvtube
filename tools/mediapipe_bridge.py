#!/usr/bin/env python3
"""
MediaPipe Face Tracking Bridge for VRMVTube

This script captures face tracking data using MediaPipe and sends it to VRMVTube
via UDP. It provides real-time face tracking for VRM avatar animation.

Requirements:
    pip install mediapipe opencv-python numpy

Usage:
    python mediapipe_bridge.py

Configuration:
    - GODOT_IP: IP address where VRMVTube is running (default: 127.0.0.1)
    - GODOT_PORT: UDP port for communication (default: 9999)
    - CAMERA_ID: Camera device ID (default: 0)
    - FPS: Tracking frames per second (default: 30)
"""

import cv2
import mediapipe as mp
import socket
import json
import time
import math
import numpy as np
from typing import Optional, Dict, Any

# Configuration
GODOT_IP = "127.0.0.1"
GODOT_PORT = 9999
CAMERA_ID = 0
FPS = 30
SHOW_PREVIEW = True  # Show camera preview window

# MediaPipe setup
mp_face_mesh = mp.solutions.face_mesh
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles

# Key landmark indices for calculations
LEFT_EYE_INDICES = [33, 160, 158, 133, 153, 144]
RIGHT_EYE_INDICES = [362, 385, 387, 263, 373, 380]
MOUTH_INDICES = [61, 291, 0, 17]  # Corners and center points


def calculate_eye_aspect_ratio(landmarks, eye_indices) -> float:
    """Calculate Eye Aspect Ratio (EAR) for blink detection"""
    points = [landmarks[i] for i in eye_indices]
    
    # Vertical distances
    v1 = math.dist([points[1].x, points[1].y], [points[5].x, points[5].y])
    v2 = math.dist([points[2].x, points[2].y], [points[4].x, points[4].y])
    
    # Horizontal distance
    h = math.dist([points[0].x, points[0].y], [points[3].x, points[3].y])
    
    # EAR formula
    ear = (v1 + v2) / (2.0 * h)
    return ear


def calculate_blink(landmarks, eye: str) -> float:
    """Calculate blink value (0.0 = open, 1.0 = closed)"""
    if eye == "left":
        indices = LEFT_EYE_INDICES
    else:
        indices = RIGHT_EYE_INDICES
    
    ear = calculate_eye_aspect_ratio(landmarks, indices)
    
    # Normalize EAR to 0-1 range (adjust thresholds based on testing)
    # Typical EAR: ~0.25 when open, ~0.10 when closed
    blink = 1.0 - ((ear - 0.10) / (0.25 - 0.10))
    return max(0.0, min(1.0, blink))


def calculate_mouth_open(landmarks) -> float:
    """Calculate mouth openness (0.0 = closed, 1.0 = fully open)"""
    # Get upper and lower lip landmarks
    upper_lip = landmarks[13]  # Landmark 13: upper lip
    lower_lip = landmarks[14]  # Landmark 14: lower lip
    
    # Calculate vertical distance
    mouth_height = abs(upper_lip.y - lower_lip.y)
    
    # Normalize (adjust based on testing)
    # Typical range: ~0.01 closed, ~0.08 fully open
    mouth_open = (mouth_height - 0.01) / (0.08 - 0.01)
    return max(0.0, min(1.0, mouth_open))


def calculate_head_rotation(landmarks, image_width: int, image_height: int) -> Dict[str, float]:
    """Calculate head rotation (pitch, yaw, roll)"""
    # Use specific landmarks for head pose estimation
    nose_tip = landmarks[1]
    chin = landmarks[152]
    left_eye = landmarks[33]
    right_eye = landmarks[263]
    left_mouth = landmarks[61]
    right_mouth = landmarks[291]
    
    # Simple approximation of head rotation
    # For production, use cv2.solvePnP with 3D model points
    
    # Yaw (left-right rotation)
    eye_center_x = (left_eye.x + right_eye.x) / 2
    yaw = (nose_tip.x - eye_center_x) * 2.0  # Normalize to radians
    
    # Pitch (up-down rotation)
    eye_center_y = (left_eye.y + right_eye.y) / 2
    pitch = (nose_tip.y - eye_center_y) * 2.0
    
    # Roll (head tilt)
    roll = math.atan2(right_eye.y - left_eye.y, right_eye.x - left_eye.x)
    
    return {
        "x": pitch,
        "y": yaw,
        "z": roll
    }


def process_face_landmarks(face_landmarks, image_width: int, image_height: int) -> Dict[str, Any]:
    """Process face landmarks and extract tracking data"""
    landmarks = face_landmarks.landmark
    
    # Calculate tracking values
    blink_left = calculate_blink(landmarks, "left")
    blink_right = calculate_blink(landmarks, "right")
    mouth_open = calculate_mouth_open(landmarks)
    head_rotation = calculate_head_rotation(landmarks, image_width, image_height)
    
    # Build tracking data dictionary
    tracking_data = {
        "blink_left": blink_left,
        "blink_right": blink_right,
        "mouth_open": mouth_open,
        "smile": 0.0,  # TODO: Implement smile detection
        "head_rotation": head_rotation,
        "head_position": {"x": 0.0, "y": 0.0, "z": 0.0},
        "tracking_quality": 1.0,
        "timestamp": time.time()
    }
    
    return tracking_data


def main():
    """Main function to run face tracking and send data to VRMVTube"""
    print("=" * 60)
    print("MediaPipe Face Tracking Bridge for VRMVTube")
    print("=" * 60)
    print(f"Target: {GODOT_IP}:{GODOT_PORT}")
    print(f"Camera: {CAMERA_ID}")
    print(f"FPS: {FPS}")
    print("Press 'q' to quit")
    print("=" * 60)
    
    # Setup UDP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    # Open camera
    cap = cv2.VideoCapture(CAMERA_ID)
    if not cap.isOpened():
        print(f"ERROR: Could not open camera {CAMERA_ID}")
        return
    
    # Set camera properties
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FPS, FPS)
    
    # Initialize MediaPipe Face Mesh
    with mp_face_mesh.FaceMesh(
        max_num_faces=1,
        refine_landmarks=True,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5
    ) as face_mesh:
        
        frame_count = 0
        start_time = time.time()
        last_print_time = start_time
        
        while cap.isOpened():
            success, image = cap.read()
            if not success:
                print("WARNING: Failed to read frame")
                continue
            
            # Flip image horizontally for selfie view
            image = cv2.flip(image, 1)
            
            # Convert BGR to RGB
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            
            # Process with MediaPipe
            results = face_mesh.process(image_rgb)
            
            # Extract tracking data
            if results.multi_face_landmarks:
                face_landmarks = results.multi_face_landmarks[0]
                
                # Get image dimensions
                h, w = image.shape[:2]
                
                # Process landmarks
                tracking_data = process_face_landmarks(face_landmarks, w, h)
                
                # Send to VRMVTube via UDP
                try:
                    json_data = json.dumps(tracking_data)
                    sock.sendto(json_data.encode('utf-8'), (GODOT_IP, GODOT_PORT))
                except Exception as e:
                    print(f"ERROR sending data: {e}")
                
                # Draw landmarks on preview
                if SHOW_PREVIEW:
                    mp_drawing.draw_landmarks(
                        image=image,
                        landmark_list=face_landmarks,
                        connections=mp_face_mesh.FACEMESH_TESSELATION,
                        landmark_drawing_spec=None,
                        connection_drawing_spec=mp_drawing_styles.get_default_face_mesh_tesselation_style()
                    )
                    
                    # Draw tracking info
                    cv2.putText(image, f"Blink L: {tracking_data['blink_left']:.2f}", 
                               (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
                    cv2.putText(image, f"Blink R: {tracking_data['blink_right']:.2f}", 
                               (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
                    cv2.putText(image, f"Mouth: {tracking_data['mouth_open']:.2f}", 
                               (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
            else:
                # No face detected
                if SHOW_PREVIEW:
                    cv2.putText(image, "No face detected", 
                               (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)
            
            # Show preview window
            if SHOW_PREVIEW:
                cv2.imshow('MediaPipe Face Tracking', image)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
            
            # Update frame count and print stats
            frame_count += 1
            current_time = time.time()
            if current_time - last_print_time >= 5.0:
                elapsed = current_time - start_time
                fps = frame_count / elapsed
                print(f"Frames: {frame_count}, FPS: {fps:.1f}, "
                      f"Face: {'Yes' if results.multi_face_landmarks else 'No'}")
                last_print_time = current_time
    
    # Cleanup
    cap.release()
    cv2.destroyAllWindows()
    sock.close()
    print("\nTracking stopped.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nInterrupted by user")
    except Exception as e:
        print(f"\nERROR: {e}")
        import traceback
        traceback.print_exc()
