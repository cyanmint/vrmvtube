extends Node

## Cross-Platform Tracking Manager
##
## Automatically selects and manages the best face tracking method for each platform:
## - Desktop (Windows/macOS/Linux): MediaPipe Python bridge or simulated
## - Web: JavaScript MediaPipe (via HTML interface)
## - Android: Native camera with basic tracking
## - All: Enhanced fallback tracking
##
## Created by: GitHub Copilot

signal tracking_method_changed(method: String)

enum TrackingMethod {
	SIMULATED,      # Built-in animated tracking
	MEDIAPIPE_UDP,  # Python MediaPipe bridge (Desktop)
	MEDIAPIPE_WEB,  # JavaScript MediaPipe (Web)
	NATIVE_CAMERA,  # Native camera processing (Android/iOS)
	VMC_PROTOCOL,   # VMC (Virtual Motion Capture) protocol
	OPENSEEFACE     # OpenSeeFace tracking
}

var current_method: TrackingMethod = TrackingMethod.SIMULATED
var platform: String
var available_methods: Array[TrackingMethod] = []

func _ready() -> void:
	platform = OS.get_name()
	print("TrackingManager: Platform detected: ", platform)
	_detect_available_methods()
	_select_best_method()

func _detect_available_methods() -> void:
	"""Detect which tracking methods are available on this platform"""
	available_methods.clear()
	
	# Simulated tracking is always available
	available_methods.append(TrackingMethod.SIMULATED)
	
	match platform:
		"Windows", "macOS", "Linux", "X11":
			# Desktop platforms support multiple methods
			available_methods.append(TrackingMethod.OPENSEEFACE)
			available_methods.append(TrackingMethod.MEDIAPIPE_UDP)
			available_methods.append(TrackingMethod.VMC_PROTOCOL)
			print("TrackingManager: Desktop platform - OpenSeeFace, MediaPipe, VMC available")
		
		"Web", "HTML5":
			# Web platform uses JavaScript MediaPipe
			available_methods.append(TrackingMethod.MEDIAPIPE_WEB)
			available_methods.append(TrackingMethod.VMC_PROTOCOL)
			print("TrackingManager: Web platform - JavaScript MediaPipe, VMC available")
		
		"Android":
			# Android can use native camera
			available_methods.append(TrackingMethod.NATIVE_CAMERA)
			print("TrackingManager: Android platform - Native camera available")
		
		"iOS":
			# iOS can use native camera
			available_methods.append(TrackingMethod.NATIVE_CAMERA)
			print("TrackingManager: iOS platform - Native camera available")
	
	print("TrackingManager: Available methods: ", available_methods)

func _select_best_method() -> void:
	"""Automatically select the best tracking method for this platform"""
	# Priority order (best to worst):
	# 1. OpenSeeFace (most accurate)
	# 2. VMC Protocol (interoperability)
	# 3. MediaPipe (UDP or Web)
	# 4. Native Camera
	# 5. Simulated
	
	if TrackingMethod.OPENSEEFACE in available_methods:
		set_tracking_method(TrackingMethod.OPENSEEFACE)
	elif TrackingMethod.VMC_PROTOCOL in available_methods:
		set_tracking_method(TrackingMethod.VMC_PROTOCOL)
	elif TrackingMethod.MEDIAPIPE_UDP in available_methods:
		set_tracking_method(TrackingMethod.MEDIAPIPE_UDP)
	elif TrackingMethod.MEDIAPIPE_WEB in available_methods:
		set_tracking_method(TrackingMethod.MEDIAPIPE_WEB)
	elif TrackingMethod.NATIVE_CAMERA in available_methods:
		set_tracking_method(TrackingMethod.NATIVE_CAMERA)
	else:
		set_tracking_method(TrackingMethod.SIMULATED)

func set_tracking_method(method: TrackingMethod) -> void:
	"""Set the active tracking method"""
	if method not in available_methods:
		push_warning("TrackingManager: Method %s not available on %s" % [method, platform])
		return
	
	current_method = method
	tracking_method_changed.emit(get_method_name(method))
	print("TrackingManager: Active method: ", get_method_name(method))

func get_method_name(method: TrackingMethod) -> String:
	"""Get human-readable name for tracking method"""
	match method:
		TrackingMethod.SIMULATED:
			return "Simulated"
		TrackingMethod.MEDIAPIPE_UDP:
			return "MediaPipe (Python)"
		TrackingMethod.MEDIAPIPE_WEB:
			return "MediaPipe (Web)"
		TrackingMethod.NATIVE_CAMERA:
			return "Native Camera"
		TrackingMethod.VMC_PROTOCOL:
			return "VMC Protocol"
		TrackingMethod.OPENSEEFACE:
			return "OpenSeeFace"
		_:
			return "Unknown"

func get_current_method() -> TrackingMethod:
	"""Get the currently active tracking method"""
	return current_method

func get_method_description() -> String:
	"""Get description of current tracking method"""
	match current_method:
		TrackingMethod.SIMULATED:
			return "Built-in animated tracking for demonstration"
		TrackingMethod.MEDIAPIPE_UDP:
			return "Real face tracking via Python MediaPipe bridge"
		TrackingMethod.MEDIAPIPE_WEB:
			return "Real face tracking via JavaScript MediaPipe in browser"
		TrackingMethod.NATIVE_CAMERA:
			return "Real face tracking using device camera"
		TrackingMethod.VMC_PROTOCOL:
			return "Receive tracking from VMC-compatible apps (VSeeFace, etc.)"
		TrackingMethod.OPENSEEFACE:
			return "High-accuracy face tracking via OpenSeeFace"
		_:
			return "Unknown tracking method"

func get_setup_instructions() -> String:
	"""Get setup instructions for current method"""
	match current_method:
		TrackingMethod.SIMULATED:
			return "No setup needed - tracking is active"
		TrackingMethod.MEDIAPIPE_UDP:
			return "Run: pip install -r tools/requirements.txt\nThen: python tools/mediapipe_bridge.py"
		TrackingMethod.MEDIAPIPE_WEB:
			return "Open tools/web_tracking.html in your browser and click 'Start Tracking'"
		TrackingMethod.NATIVE_CAMERA:
			return "Grant camera permissions when prompted"
		TrackingMethod.VMC_PROTOCOL:
			return "Start a VMC sender app (VSeeFace, VMC, Warudo)\nSet output to port 39539"
		TrackingMethod.OPENSEEFACE:
			return "Install: pip install onnxruntime opencv-python pillow numpy\nRun: python facetracker.py --ip 127.0.0.1 --port 11573"
		_:
			return ""

func is_real_tracking() -> bool:
	"""Check if current method uses real face tracking (not simulated)"""
	return current_method != TrackingMethod.SIMULATED

func get_status_info() -> Dictionary:
	"""Get complete status information"""
	return {
		"platform": platform,
		"current_method": get_method_name(current_method),
		"is_real_tracking": is_real_tracking(),
		"description": get_method_description(),
		"setup_instructions": get_setup_instructions(),
		"available_methods": available_methods.map(func(m): return get_method_name(m))
	}
