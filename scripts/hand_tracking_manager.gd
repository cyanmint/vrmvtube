extends Node
class_name HandTrackingManager

# Hand tracking manager using MediaPipe Hand Landmarker
# Based on GDMP demo: https://github.com/j20001970/GDMP-demo

signal hand_landmarks_updated(landmarks: Array)
signal tracking_error(error_message: String)

var hand_landmarker: MediaPipeHandLandmarker
var camera_feed: CameraFeed
var is_tracking: bool = false
var model_path: String = "res://assets/models/mediapipe/hand_landmarker.task"

# Hand landmark indices (MediaPipe Hand Landmarker)
enum HandLandmark {
	WRIST = 0,
	THUMB_CMC = 1,
	THUMB_MCP = 2,
	THUMB_IP = 3,
	THUMB_TIP = 4,
	INDEX_FINGER_MCP = 5,
	INDEX_FINGER_PIP = 6,
	INDEX_FINGER_DIP = 7,
	INDEX_FINGER_TIP = 8,
	MIDDLE_FINGER_MCP = 9,
	MIDDLE_FINGER_PIP = 10,
	MIDDLE_FINGER_DIP = 11,
	MIDDLE_FINGER_TIP = 12,
	RING_FINGER_MCP = 13,
	RING_FINGER_PIP = 14,
	RING_FINGER_DIP = 15,
	RING_FINGER_TIP = 16,
	PINKY_MCP = 17,
	PINKY_PIP = 18,
	PINKY_DIP = 19,
	PINKY_TIP = 20
}

func _ready() -> void:
	print("[HandTracking] Initializing hand tracking manager")

func initialize() -> bool:
	print("[HandTracking] Loading model from: ", model_path)
	
	# Check if MediaPipe classes are available
	if not ClassDB.class_exists("MediaPipeHandLandmarker"):
		push_error("[HandTracking] MediaPipeHandLandmarker class not found. GDMP plugin may not be loaded.")
		tracking_error.emit("GDMP plugin not available")
		return false
	
	# Load model file
	if not FileAccess.file_exists(model_path):
		push_error("[HandTracking] Model file not found: ", model_path)
		tracking_error.emit("Hand landmarker model not found")
		return false
	
	var file := FileAccess.open(model_path, FileAccess.READ)
	if file == null:
		push_error("[HandTracking] Failed to open model file: ", model_path)
		tracking_error.emit("Failed to load hand landmarker model")
		return false
	
	var model_buffer := file.get_buffer(file.get_length())
	file.close()
	
	# Create base options
	var base_options := MediaPipeTaskBaseOptions.new()
	base_options.delegate = MediaPipeTaskBaseOptions.Delegate.CPU
	base_options.model_asset_buffer = model_buffer
	
	# Create hand landmarker
	hand_landmarker = MediaPipeHandLandmarker.new()
	var running_mode = MediaPipeTask.RunningMode.LIVE_STREAM
	hand_landmarker.initialize(base_options, running_mode)
	hand_landmarker.result_callback.connect(_on_hand_result)
	
	print("[HandTracking] Hand landmarker initialized successfully")
	return true

func start_tracking() -> bool:
	if hand_landmarker == null:
		if not initialize():
			return false
	
	# Get default camera
	var camera_index := 0
	if CameraServer.get_feed_count() > 0:
		camera_feed = CameraServer.get_feed(camera_index)
		if camera_feed:
			camera_feed.feed_is_active = true
			is_tracking = true
			print("[HandTracking] Camera feed activated")
			return true
	
	push_error("[HandTracking] No camera feed available")
	tracking_error.emit("No camera found")
	return false

func stop_tracking() -> void:
	is_tracking = false
	if camera_feed:
		camera_feed.feed_is_active = false
	print("[HandTracking] Tracking stopped")

func process_frame(image: Image, timestamp_ms: int) -> void:
	if not is_tracking or hand_landmarker == null:
		return
	
	var mediapipe_image := MediaPipeImage.new()
	mediapipe_image.set_image(image)
	hand_landmarker.detect_async(mediapipe_image, timestamp_ms)

func _on_hand_result(result: MediaPipeHandLandmarkerResult, image: MediaPipeImage, timestamp_ms: int) -> void:
	if result and result.hand_landmarks.size() > 0:
		hand_landmarks_updated.emit(result.hand_landmarks)

func get_hand_landmarks() -> Array:
	# Returns the most recent hand landmarks
	# Called from main process loop
	return []
