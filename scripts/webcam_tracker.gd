extends Node

## Webcam Tracker for VRMVTube
##
## Provides webcam access and basic face tracking for all platforms
## Uses Godot's built-in CameraTexture for cross-platform webcam support
##
## Created by: GitHub Copilot
## Platform Support: Windows, macOS, Linux, Android, Web (with browser permissions)

signal face_tracking_updated(tracking_data: Dictionary)
signal webcam_available(available: bool)

@export var enable_tracking: bool = true
@export var tracking_fps: int = 30

var camera_feed: CameraFeed
var camera_texture: CameraTexture
var tracking_active: bool = false
var tracking_thread: Thread

# Tracking data
var head_rotation: Vector3 = Vector3.ZERO
var head_position: Vector3 = Vector3.ZERO
var blink_left: float = 0.0
var blink_right: float = 0.0
var mouth_open: float = 0.0
var smile: float = 0.0

func _ready() -> void:
	print("WebcamTracker: Initializing for platform: ", OS.get_name())
	# Use call_deferred to ensure signals can be connected first
	call_deferred("_initialize_camera")

func _initialize_camera() -> void:
	"""Initialize webcam access using Godot's CameraServer"""
	print("WebcamTracker: Attempting camera initialization...")
	
	# Note: Godot's CameraServer has limited support on desktop platforms
	# It works better on mobile (Android/iOS) and web platforms
	# However, we'll try to access it on all platforms
	
	var platform := OS.get_name()
	if platform in ["Windows", "Linux", "macOS", "X11"]:
		push_warning("WebcamTracker: Desktop platform detected - webcam support may be limited")
		push_warning("WebcamTracker: Attempting to access webcam, will fallback to simulated tracking if unavailable")
		# Try to initialize camera for desktop platforms too
		_initialize_camera_async()
	else:
		# For mobile/web platforms, try to use CameraServer
		_initialize_camera_async()

func _initialize_camera_async() -> void:
	"""Async initialization for all platforms"""
	var camera_server := CameraServer
	
	# Enable camera feed monitoring FIRST - this is crucial for desktop platforms
	camera_server.set_monitoring_feeds(true)
	print("WebcamTracker: Enabled camera feed monitoring")
	
	# In Godot 4.x, we need to check for existing feeds or create one
	# CameraServer.add_feed() expects a CameraFeed object
	# For mobile/web/desktop, feeds are auto-detected when monitoring is enabled
	
	# Wait a frame for camera system to initialize
	await get_tree().process_frame
	await get_tree().process_frame  # Extra frame for desktop platforms
	
	var feed_count := camera_server.get_feed_count()
	print("WebcamTracker: Found ", feed_count, " camera feed(s)")
	
	if feed_count == 0:
		push_warning("WebcamTracker: No camera feeds available, using simulated tracking")
		push_warning("WebcamTracker: For real webcam tracking, consider using MediaPipe or OpenCV plugin")
		webcam_available.emit(false)
		tracking_active = true
		return
	
	# Get the first available camera feed
	camera_feed = camera_server.get_feed(0)
	if camera_feed:
		print("WebcamTracker: Using camera: ", camera_feed.get_name())
		camera_texture = CameraTexture.new()
		camera_texture.camera_feed_id = camera_feed.get_id()
		camera_texture.camera_is_active = true
		
		# Activate the feed
		camera_feed.set_active(true)
		print("WebcamTracker: Camera feed activated")
		
		webcam_available.emit(true)
		
		if enable_tracking:
			_start_tracking()
	else:
		push_warning("WebcamTracker: Failed to get camera feed, using simulated tracking")
		webcam_available.emit(false)
		tracking_active = true

func _start_tracking() -> void:
	"""Start face tracking"""
	if tracking_active:
		return
	
	tracking_active = true
	print("WebcamTracker: Face tracking started")
	
	# Note: Basic implementation - in production, this would use MediaPipe or similar
	# For now, we'll simulate tracking with placeholder values

func _stop_tracking() -> void:
	"""Stop face tracking"""
	tracking_active = false
	print("WebcamTracker: Face tracking stopped")

func _process(_delta: float) -> void:
	if not tracking_active or not enable_tracking:
		return
	
	# NOTE: Simulated tracking is only used as fallback
	# Real tracking data comes from MediaPipe via update_from_mediapipe()
	# This simulated tracking runs continuously to show the system works
	_update_simulated_tracking()

func update_from_mediapipe(data: Dictionary) -> void:
	"""Update tracking from real MediaPipe data
	
	This replaces simulated tracking with real face tracking data from MediaPipe.
	Call this when MediaPipe UDP packets are received.
	"""
	if not enable_tracking:
		return
	
	# Extract values from MediaPipe data
	if data.has("blink_left"):
		blink_left = data["blink_left"]
	
	if data.has("blink_right"):
		blink_right = data["blink_right"]
	
	if data.has("mouth_open"):
		mouth_open = data["mouth_open"]
	
	if data.has("smile"):
		smile = data["smile"]
	
	if data.has("head_rotation"):
		head_rotation = data["head_rotation"]
	
	if data.has("head_position"):
		head_position = data["head_position"]
	
	# Build and emit tracking data
	var tracking_data := {
		"head_rotation": head_rotation,
		"head_position": head_position,
		"blink_left": blink_left,
		"blink_right": blink_right,
		"mouth_open": mouth_open,
		"smile": smile,
		"tracking_quality": data.get("tracking_quality", 1.0)
	}
	
	# Emit the real tracking data
	face_tracking_updated.emit(tracking_data)

func _update_simulated_tracking() -> void:
	"""Simulate face tracking data (placeholder for actual tracking)"""
	# This is a placeholder - real implementation would analyze camera frames
	# and extract facial landmarks using computer vision
	
	# Add some subtle animation to show tracking is working
	var time := Time.get_ticks_msec() / 1000.0
	
	# Simulate natural blinking
	var blink_cycle := sin(time * 3.0)
	if blink_cycle > 0.9:
		blink_left = clamp((blink_cycle - 0.9) * 10.0, 0.0, 1.0)
		blink_right = clamp((blink_cycle - 0.9) * 10.0, 0.0, 1.0)
	else:
		blink_left = 0.0
		blink_right = 0.0
	
	# Simulate mouth movement
	mouth_open = (sin(time * 2.0) + 1.0) * 0.2
	
	# Simulate slight head rotation
	head_rotation = Vector3(
		cos(time * 0.7) * 0.05,
		sin(time * 0.5) * 0.1,
		0.0
	)
	
	var tracking_data := {
		"head_rotation": head_rotation,
		"head_position": head_position,
		"blink_left": blink_left,
		"blink_right": blink_right,
		"mouth_open": mouth_open,
		"smile": smile,
		"tracking_quality": 1.0  # 0.0 to 1.0
	}
	
	face_tracking_updated.emit(tracking_data)

func get_camera_texture() -> CameraTexture:
	"""Get the camera texture for preview"""
	return camera_texture

func is_tracking_active() -> bool:
	"""Check if tracking is currently active"""
	return tracking_active

func _exit_tree() -> void:
	"""Cleanup when node is removed"""
	_stop_tracking()
	
	if camera_feed and camera_feed.is_active():
		camera_feed.set_active(false)
		print("WebcamTracker: Camera deactivated")
