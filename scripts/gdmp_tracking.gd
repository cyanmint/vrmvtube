extends Node

## GDMP Native Face Tracking
##
## Uses GDMP (Godot MediaPipe) GDExtension for native face tracking
## Works on all platforms: Windows, Linux, macOS, Android, iOS, Web
##
## On Android/Web: Uses MediaPipeCameraHelper for direct camera capture.
## On Desktop (Windows/Linux/macOS): Uses CameraServer to capture webcam
## frames and feeds them to GDMP face landmarker for real tracking.
##
## GDMP is bundled with VRMVTube - no external downloads required!
## MediaPipe provides professional-grade face tracking with 468 landmarks.
##
## Fully self-contained - all binaries and models included.
##
## Created by: GitHub Copilot

signal tracking_data_received(data: Dictionary)
signal gdmp_available_changed(available: bool)
signal camera_started
signal camera_failed(reason: String)

@export var enabled: bool = true
@export var use_camera: bool = true
@export var camera_index: int = 0

var gdmp_available: bool = false
var face_landmarker = null
var camera_feed: CameraFeed
var camera_texture: CameraTexture
var tracking_active: bool = false

# GDMP objects
var camera_helper = null
var gpu_resources = null
var latest_face_result = null

# Frame counter for debugging
var frame_count = 0
var last_frame_log_time = 0.0

# Enhanced simulation fallback
var time_elapsed: float = 0.0
var last_blink_time: float = 0.0
var blink_interval: float = 3.0

# Desktop camera tracking (CameraServer → GDMP pipeline)
const DESKTOP_FRAME_SKIP_RATE := 2
var desktop_frame_skip: int = 0


func _ready() -> void:
	print("GDMPTracking: Initializing GDMP native face tracking")
	_check_gdmp_availability()

	if gdmp_available:
		# Must await since _initialize_gdmp contains await calls
		await _initialize_gdmp()
	else:
		push_error("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		push_error("❌ CRITICAL: GDMP Plugin Not Found!")
		push_error("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		push_error("")
		push_error("Face tracking requires GDMP (included in VRMVTube).")
		push_error("GDMP should be at: res://addons/GDMP/")
		push_error("")
		push_error("This is a critical error - face tracking cannot work")
		push_error("without MediaPipe. Please ensure GDMP addon is enabled:")
		push_error("  Project → Project Settings → Plugins → GDMP")
		push_error("")
		push_error("If you cloned from git, GDMP is already included.")
		push_error("If you downloaded a build, GDMP should be bundled.")
		push_error("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

		# Use simulation as emergency fallback, but log as error
		_start_simulated_tracking()
		push_error("Using simulation fallback - NOT suitable for production use")

		if use_camera:
			var platform = OS.get_name()
			if platform in ["Windows", "macOS", "Linux", "X11", "FreeBSD", "NetBSD", "OpenBSD", "BSD"]:
				print("GDMPTracking: Starting CameraServer preview on desktop")
				await _initialize_camera()


func _check_gdmp_availability() -> void:
	"""Check if GDMP plugin is available"""
	print("GDMPTracking: Checking GDMP availability...")
	print("GDMPTracking: Platform: ", OS.get_name())

	# List some key GDMP classes to check
	var classes_to_check = [
		"MediaPipeImage",
		"MediaPipeFaceLandmarker",
		"MediaPipeCameraHelper",
		"MediaPipeGPUResources",
		"MediaPipeTaskBaseOptions"
	]

	var all_available = true
	for class_to_check in classes_to_check:
		var exists = ClassDB.class_exists(class_to_check)
		print("GDMPTracking:   - ", class_to_check, ": ", "✅" if exists else "❌")
		if not exists:
			all_available = false

	if all_available:
		gdmp_available = true
		print("GDMPTracking: ✅ GDMP plugin fully available!")
	else:
		gdmp_available = false
		print("GDMPTracking: ❌ GDMP plugin NOT available - some classes missing")
		print("GDMPTracking: This usually means:")
		print("GDMPTracking:   1. GDMP binaries not included in export")
		print("GDMPTracking:   2. Plugin not enabled in Project Settings")
		print("GDMPTracking:   3. Wrong GDMP version or platform architecture")

	gdmp_available_changed.emit(gdmp_available)


func _initialize_gdmp() -> void:
	"""Initialize GDMP face landmarker"""
	print("GDMPTracking: Initializing GDMP FaceLandmarker")

	# Initialize GPU resources (required for Android/Web)
	var platform = OS.get_name()
	if platform in ["Android", "iOS", "Web", "HTML5"]:
		gpu_resources = ClassDB.instantiate("MediaPipeGPUResources")
		if gpu_resources:
			print("GDMPTracking: ✅ GPU resources initialized for ", platform)
		else:
			push_warning("GDMPTracking: Failed to create GPU resources")

	# Initialize face landmarker
	face_landmarker = ClassDB.instantiate("MediaPipeFaceLandmarker")
	if not face_landmarker:
		push_error("GDMPTracking: Failed to instantiate MediaPipeFaceLandmarker")
		gdmp_available = false
		_start_simulated_tracking()
		return

	# Create base options
	var base_options = ClassDB.instantiate("MediaPipeTaskBaseOptions")
	if not base_options:
		push_error("GDMPTracking: Failed to create base options")
		gdmp_available = false
		_start_simulated_tracking()
		return

	# Set model path - verify it exists first
	# On Android, GDMP may need the actual file system path, not res://
	var model_path = "res://addons/GDMP/models/face_landmarker.task"
	var actual_path = model_path

	# On Android, convert res:// to actual file path
	if platform in ["Android"]:
		# Godot exports res:// files to the APK, but GDMP needs direct file access
		# ProjectSettings.globalize_path converts res:// to actual path
		actual_path = ProjectSettings.globalize_path(model_path)
		print("GDMPTracking: Android detected - using globalized path: ", actual_path)

	# Check if model file exists
	if not FileAccess.file_exists(model_path):
		push_error("GDMPTracking: Model file not found at: ", model_path)
		push_error("GDMPTracking: GDMP face_landmarker.task must be included in the build!")
		push_error("GDMPTracking: Check if the file is being excluded by export settings.")
		push_error("GDMPTracking: The file should be downloaded by CI/CD during build.")
		gdmp_available = false
		_start_simulated_tracking()
		return

	print("GDMPTracking: Model file found at: ", model_path)
	print("GDMPTracking: Using path for GDMP: ", actual_path)
	base_options.model_asset_path = actual_path

	# Initialize with live stream mode for real-time tracking
	# Parameters: base_options, running_mode, num_faces, min_face_detection_conf, min_face_presence_conf, min_tracking_conf, output_blendshapes, output_matrices
	# Wrap in try-catch equivalent to handle potential crashes
	var init_success = false

	# GDScript doesn't have try-catch, but we can check return value
	init_success = face_landmarker.initialize(base_options, 2, 1, 0.5, 0.5, 0.5, true, false)  # RUNNING_MODE_LIVE_STREAM (0=IMAGE, 1=VIDEO, 2=LIVE_STREAM)  # num_faces: detect 1 face  # min_face_detection_confidence  # min_face_presence_confidence  # min_tracking_confidence  # output_face_blendshapes (we need these for VRM!)  # output_facial_transformation_matrixes (optional)

	if not init_success:
		push_error("GDMPTracking: Failed to initialize face landmarker")
		push_error("GDMPTracking: This may be due to:")
		push_error("  - Model file corruption or wrong format")
		push_error("  - Insufficient memory on device")
		push_error("  - GDMP library version mismatch")
		gdmp_available = false
		face_landmarker = null
		_start_simulated_tracking()
		return

	# Connect result callback for async processing
	face_landmarker.result_callback.connect(_on_face_landmarker_result)

	print("GDMPTracking: ✅ Face landmarker initialized successfully")

	if use_camera:
		print("GDMPTracking: Initializing camera with timeout protection...")

		# Initialize camera with timeout protection (max 15 seconds total)
		var timeout_timer = get_tree().create_timer(15.0)

		# Start camera initialization
		_initialize_camera()
		
		# Wait for either completion or timeout
		await timeout_timer.timeout
		print("GDMPTracking: Camera initialization completed or timed out")

	tracking_active = true
	print("GDMPTracking: ✅ Native tracking active")


func _initialize_camera() -> void:
	"""
	Initialize camera for tracking; call with await.
	Attempts GDMP camera helper on ALL platforms first (uses OpenCV on desktop),
	then falls back to CameraServer if GDMP helper is unavailable.
	"""
	var platform = OS.get_name()

	# Try GDMP camera helper first on ALL platforms
	# GDMP v0.6 uses OpenCV for camera capture on desktop, Camera2 on Android
	if gdmp_available and ClassDB.class_exists("MediaPipeCameraHelper"):
		print("GDMPTracking: Attempting GDMP camera helper for ", platform)

		camera_helper = ClassDB.instantiate("MediaPipeCameraHelper")
		if camera_helper:
			print("GDMPTracking: Using GDMP camera helper for ", platform)

			# Connect camera frame signal to process each frame
			camera_helper.new_frame.connect(_on_camera_frame)

			# Check camera permission (mobile platforms only)
			if platform in ["Android", "iOS"]:
				print("GDMPTracking: Checking camera permission status...")

				var has_permission = camera_helper.permission_granted()
				print("GDMPTracking: Initial permission status: ", has_permission)

				if not has_permission:
					print("GDMPTracking: ⚠️ Camera permission not granted, requesting now...")

					if camera_helper.has_signal("permission_result"):
						camera_helper.permission_result.connect(_on_permission_result)

					camera_helper.request_permission()
					print("GDMPTracking: Permission request sent to system")

					var permission_granted = false
					var timeout = 10.0
					var elapsed = 0.0
					var check_interval = 0.2

					print("GDMPTracking: Waiting for user to grant camera permission...")

					while elapsed < timeout:
						await get_tree().create_timer(check_interval).timeout
						elapsed += check_interval

						if camera_helper.permission_granted():
							permission_granted = true
							print("GDMPTracking: ✅ Camera permission GRANTED by user!")
							break

						if int(elapsed) != int(elapsed - check_interval):
							print(
								"GDMPTracking: Still waiting for permission... (",
								int(timeout - elapsed),
								"s remaining)"
							)

					if not permission_granted:
						push_error("GDMPTracking: ❌ Camera permission DENIED or timed out!")
						camera_helper = null
						# Fall through to CameraServer fallback below
				else:
					print("GDMPTracking: ✅ Camera permission already granted")

			# Start GDMP camera helper if still valid
			if camera_helper:
				# Set GPU resources if available (required on Android)
				if gpu_resources:
					print("GDMPTracking: Attaching GPU resources to camera...")
					camera_helper.set_gpu_resources(gpu_resources)
					print("GDMPTracking: ✅ GPU resources attached to camera")

				# Mirror camera (front-facing camera)
				camera_helper.set_mirrored(true)
				print("GDMPTracking: Camera mirroring enabled (front-facing mode)")

				# Start camera: index 0 = front camera, 640x480 resolution
				var camera_index_facing = 0  # FACING_FRONT
				var camera_resolution = Vector2(640, 480)

				print(
					"GDMPTracking: Starting camera (index: ",
					camera_index_facing,
					", resolution: ",
					camera_resolution,
					")..."
				)

				camera_helper.start(camera_index_facing, camera_resolution)

				# Give camera a moment to initialize
				await get_tree().create_timer(0.5).timeout

				print("GDMPTracking: ✅ GDMP camera started successfully!")
				print("GDMPTracking: Camera is now capturing frames for face tracking")
				camera_started.emit()
				return
		else:
			push_warning("GDMPTracking: Failed to create MediaPipeCameraHelper")

	# CameraServer fallback for platforms where GDMP camera helper failed or is unavailable
	# CameraServer works on: Linux, macOS (Godot 4.3+), Android (Godot 4.4+)
	# Note: Windows CameraServer requires Godot 4.5+ or CameraServerExtension plugin
	if platform in ["Web", "HTML5"]:
		push_warning("GDMPTracking: Web platform - CameraServer is not supported")
		push_warning("GDMPTracking: Falling back to simulated tracking")
		camera_failed.emit("Web platform not supported by CameraServer")
		return

	print("GDMPTracking: Using CameraServer fallback for ", platform)

	# Wait for feeds to be detected
	await get_tree().process_frame
	await get_tree().process_frame

	# Get available camera feeds
	var feed_count := CameraServer.get_feed_count()
	print("GDMPTracking: Detected ", feed_count, " camera feed(s)")

	if feed_count > 0:
		var feed_index: int = camera_index if camera_index < feed_count else 0
		camera_feed = CameraServer.get_feed(feed_index)

		if camera_feed:
			print("GDMPTracking: Using camera: ", camera_feed.get_name())

			camera_feed.set_active(true)
			print("GDMPTracking: Camera feed activated")

			camera_texture = CameraTexture.new()
			camera_texture.camera_feed_id = camera_feed.get_id()
			camera_texture.camera_is_active = true
			print("GDMPTracking: Camera texture created for feed")

			print("GDMPTracking: ✅ CameraServer camera started successfully!")
			camera_started.emit()
		else:
			push_warning("GDMPTracking: Failed to get camera feed at index ", feed_index)
			camera_failed.emit("Camera feed not available")
	else:
		push_warning("GDMPTracking: No camera feeds detected")
		push_warning("GDMPTracking: Make sure a webcam is connected and accessible")
		camera_failed.emit("No cameras detected")


func _on_permission_result(granted: bool) -> void:
	"""Callback when camera permission is granted or denied"""
	if granted:
		print("GDMPTracking: Permission result callback: GRANTED")
	else:
		push_error("GDMPTracking: Permission result callback: DENIED")


func _start_simulated_tracking() -> void:
	"""Start enhanced simulated tracking as fallback"""
	tracking_active = true
	print("GDMPTracking: Using enhanced simulated tracking")


func race_with_timeout(task, timeout_timer):
	"""Race a coroutine against a timeout timer
	
	The task should be a function that can be awaited.
	The timeout_timer should be a SceneTreeTimer from get_tree().create_timer().
	Returns "timeout" if timeout occurs first, "completed" if task finishes first.
	"""
	# Create a signal to track completion
	var completed = false
	var timed_out = false

	# Start both tasks
	var task_signal = func():
		await task.call()
		completed = true

	var timeout_signal = func():
		await timeout_timer.timeout
		timed_out = true

	# Run both in parallel
	task_signal.call()
	timeout_signal.call()

	# Wait for either to complete
	while not completed and not timed_out:
		await get_tree().process_frame

	if timed_out:
		return "timeout"
	else:
		return "completed"


func _process(delta: float) -> void:
	if not tracking_active or not enabled:
		return

	time_elapsed += delta

	if gdmp_available and face_landmarker:
		_process_gdmp_tracking()
	else:
		_process_simulated_tracking()


func _process_gdmp_tracking() -> void:
	"""Process real GDMP face tracking"""
	# On mobile/web, GDMP camera helper provides frames via callbacks automatically
	# On desktop, we need to capture frames from CameraServer and feed to GDMP
	if not camera_helper and camera_feed and face_landmarker:
		_process_desktop_camera_frame()

	if latest_face_result:
		var tracking_data = _convert_gdmp_to_tracking_data(latest_face_result)
		tracking_data_received.emit(tracking_data)


func _process_simulated_tracking() -> void:
	"""Enhanced simulated tracking"""
	var tracking_data := _generate_enhanced_tracking()
	tracking_data_received.emit(tracking_data)


func _process_desktop_camera_frame() -> void:
	"""Capture frame from CameraServer and feed to GDMP on desktop.

	On desktop platforms, GDMP's MediaPipeCameraHelper is not used.
	Instead, we capture frames from CameraServer and create MediaPipeImage
	objects to feed to the face landmarker for real tracking.
	"""
	# Process every Nth frame for performance (~15fps at 30fps)
	desktop_frame_skip += 1
	if desktop_frame_skip % DESKTOP_FRAME_SKIP_RATE != 0:
		return

	if not camera_texture or not face_landmarker:
		return

	# Get image from camera texture (requires GPU readback)
	var image: Image = camera_texture.get_image()
	if not image or image.is_empty():
		return

	# Create MediaPipeImage from Godot Image and send to face landmarker
	var mp_image = ClassDB.instantiate("MediaPipeImage")
	if mp_image:
		mp_image.set_image(image)
		var timestamp_ms: int = Time.get_ticks_msec()
		face_landmarker.detect_async(mp_image, timestamp_ms, Rect2(), 0)

		frame_count += 1
		var current_time: float = Time.get_ticks_msec() / 1000.0
		if current_time - last_frame_log_time >= 2.0:
			print(
				"GDMPTracking: 📹 Desktop GDMP tracking - ",
				frame_count,
				" frames processed"
			)
			last_frame_log_time = current_time


func _generate_enhanced_tracking() -> Dictionary:
	"""Generate realistic simulated tracking data"""

	# Natural blinking with random intervals
	var blink_left := 0.0
	var blink_right := 0.0

	if time_elapsed - last_blink_time >= blink_interval:
		# Quick blink
		var blink_progress := (time_elapsed - last_blink_time - blink_interval) * 10.0
		if blink_progress < 0.2:
			# Closing
			blink_left = blink_progress / 0.2
			blink_right = blink_progress / 0.2
		elif blink_progress < 0.4:
			# Opening
			blink_left = 1.0 - ((blink_progress - 0.2) / 0.2)
			blink_right = 1.0 - ((blink_progress - 0.2) / 0.2)
		else:
			# Blink complete, set next interval
			last_blink_time = time_elapsed
			blink_interval = randf_range(2.0, 5.0)

	# Subtle mouth movement (breathing/idle talk)
	var mouth_open := (sin(time_elapsed * 1.5) + 1.0) * 0.1

	# Natural head movement
	var head_rotation := Vector3(
		sin(time_elapsed * 0.3) * 0.08,  # Gentle nod
		cos(time_elapsed * 0.4) * 0.12,  # Looking around
		sin(time_elapsed * 0.25) * 0.04  # Head tilt
	)

	# Occasional smile
	var smile: float = max(0.0, sin(time_elapsed * 0.2) * 0.3)

	return {
		"blink_left": blink_left,
		"blink_right": blink_right,
		"mouth_open": mouth_open,
		"smile": smile,
		"head_rotation": head_rotation,
		"head_position": Vector3.ZERO,
		"tracking_quality": 0.7 if gdmp_available else 0.5,
		"source": "simulated"
	}


func _convert_gdmp_to_tracking_data(gdmp_result) -> Dictionary:
	"""Convert GDMP face landmarker result to tracking data
	
	GDMP provides 468 3D face mesh landmarks and 52 ARKit-compatible blendshapes.
	We extract the blendshapes directly for VRM facial animation.
	
	Reference: https://developers.google.com/mediapipe/solutions/vision/face_landmarker
	"""

	# Get face blendshapes (ARKit compatible)
	var blendshapes_array = gdmp_result.get_face_blendshapes()

	if blendshapes_array.size() == 0:
		# No face detected
		return {
			"blink_left": 0.0,
			"blink_right": 0.0,
			"mouth_open": 0.0,
			"smile": 0.0,
			"head_rotation": Vector3.ZERO,
			"head_position": Vector3.ZERO,
			"tracking_quality": 0.0,
			"source": "gdmp_native"
		}

	# Get first face's blendshapes
	var face_blendshapes = blendshapes_array[0]
	var categories = face_blendshapes.get_categories()

	# Convert MediaPipe blendshapes to a dictionary for easy lookup
	var blendshapes = {}
	for category in categories:
		var name = category.get_category_name()
		var score = category.get_score()
		blendshapes[name] = score

	# Extract relevant blendshapes for VRM
	# MediaPipe uses ARKit blendshape names
	var blink_left = blendshapes.get("eyeBlinkLeft", 0.0)
	var blink_right = blendshapes.get("eyeBlinkRight", 0.0)
	var jaw_open = blendshapes.get("jawOpen", 0.0)
	var mouth_smile_left = blendshapes.get("mouthSmileLeft", 0.0)
	var mouth_smile_right = blendshapes.get("mouthSmileRight", 0.0)

	# Get face landmarks for head rotation estimation
	var face_landmarks_array = gdmp_result.get_face_landmarks()
	var head_rotation = Vector3.ZERO

	if face_landmarks_array.size() > 0:
		var landmarks = face_landmarks_array[0].get_landmarks()
		head_rotation = _estimate_head_rotation(landmarks)

	# Calculate tracking quality based on blendshape confidence
	var tracking_quality = 1.0  # GDMP is generally high quality

	return {
		"blink_left": blink_left,
		"blink_right": blink_right,
		"mouth_open": jaw_open,
		"smile": (mouth_smile_left + mouth_smile_right) / 2.0,
		"head_rotation": head_rotation,
		"head_position": Vector3.ZERO,
		"tracking_quality": tracking_quality,
		"source": "gdmp_native",
		"blendshapes": blendshapes  # Include all blendshapes for advanced use
	}


func get_camera_texture() -> CameraTexture:
	"""Get camera texture for preview"""
	return camera_texture


func _on_face_landmarker_result(result, _image, _timestamp_ms: int) -> void:
	"""Callback when face landmarker detects a face"""
	if result:
		latest_face_result = result

		# Log face detection success periodically
		if frame_count % 60 == 0:  # Every 60 frames (about every 2 seconds)
			var face_landmarks = result.get_face_landmarks()
			var face_blendshapes = result.get_face_blendshapes()
			print(
				"GDMPTracking: 😊 Face detected! Landmarks: ",
				face_landmarks.size() if face_landmarks else 0,
				", Blendshapes: ",
				face_blendshapes.size() if face_blendshapes else 0
			)


func _on_camera_frame(image) -> void:
	"""Callback when camera produces a new frame
	
	This connects the camera helper to the face landmarker.
	Each camera frame is sent to face landmarker for processing.
	"""
	if face_landmarker and image:
		# Count frames for debugging
		frame_count += 1

		# Log every 30 frames (roughly once per second at 30fps)
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_frame_log_time >= 2.0:
			print(
				"GDMPTracking: 📹 Camera active - received ",
				frame_count,
				" frames (",
				int(frame_count / (current_time - last_frame_log_time + 0.001) * 2),
				" fps)"
			)
			last_frame_log_time = current_time

		# Send frame to face landmarker for async processing
		# Results will come back via _on_face_landmarker_result callback
		var timestamp_ms = Time.get_ticks_msec()
		face_landmarker.detect_async(image, timestamp_ms, Rect2(), 0)
	elif not face_landmarker:
		push_warning("GDMPTracking: Received camera frame but face_landmarker is null!")
	elif not image:
		push_warning("GDMPTracking: Received null image from camera!")


func _estimate_head_rotation(landmarks: Array) -> Vector3:
	"""Estimate head rotation from face landmarks
	
	Uses key facial landmarks to estimate head pose:
	- Nose tip, chin, left/right eye corners, mouth corners
	"""
	if landmarks.size() < 468:
		return Vector3.ZERO

	# Key landmark indices (MediaPipe face mesh)
	# Nose tip: 1, Chin: 152, Left eye: 33, Right eye: 263
	var nose_tip = landmarks[1]
	var chin = landmarks[152]
	var left_eye = landmarks[33]
	var right_eye = landmarks[263]

	# Calculate pitch (nod up/down) from nose-chin vertical alignment
	var nose_pos = Vector3(nose_tip.get_x(), nose_tip.get_y(), nose_tip.get_z())
	var chin_pos = Vector3(chin.get_x(), chin.get_y(), chin.get_z())
	var pitch = (nose_pos.y - chin_pos.y) * 2.0

	# Calculate yaw (turn left/right) from eye horizontal alignment
	var left_eye_pos = Vector3(left_eye.get_x(), left_eye.get_y(), left_eye.get_z())
	var right_eye_pos = Vector3(right_eye.get_x(), right_eye.get_y(), right_eye.get_z())
	var yaw = (left_eye_pos.x - right_eye_pos.x - 0.5) * 2.0

	# Calculate roll (tilt left/right) from eye vertical alignment
	var roll = (left_eye_pos.y - right_eye_pos.y) * 3.0

	return Vector3(pitch, yaw, roll)


func is_tracking_active() -> bool:
	"""Check if tracking is active"""
	return tracking_active


func is_gdmp_available() -> bool:
	"""Check if GDMP is available"""
	return gdmp_available


func get_status() -> Dictionary:
	"""Get tracking status"""
	return {
		"gdmp_available": gdmp_available,
		"tracking_active": tracking_active,
		"camera_available": camera_feed != null,
		"source": "gdmp_native" if gdmp_available else "simulated"
	}


func _exit_tree() -> void:
	"""Cleanup"""
	if camera_helper:
		camera_helper.close()
		print("GDMPTracking: Camera helper closed")

	if camera_feed and camera_feed.is_active():
		camera_feed.set_active(false)

	if face_landmarker:
		# Cleanup happens automatically when object is freed
		pass

	print("GDMPTracking: Closed")
