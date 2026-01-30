extends Node
class_name FaceTrackingManager

# Face tracking manager using MediaPipe Face Landmarker
# Based on GDMP demo: https://github.com/j20001970/GDMP-demo

signal face_landmarks_updated(landmarks: Array)
signal face_blendshapes_updated(blendshapes: MediaPipeClassifications)
signal tracking_error(error_message: String)

var face_landmarker: MediaPipeFaceLandmarker
var camera_feed: CameraFeed
var is_tracking: bool = false
var model_path: String = "res://assets/models/mediapipe/face_landmarker.task"

# VRM blend shape mapping for common expressions
# MediaPipe provides 52 blendshapes, we map the most important ones
var vrm_blendshape_mapping: Dictionary = {
	"_neutral": "neutral",
	"browDownLeft": "browDownLeft",
	"browDownRight": "browDownRight",
	"browInnerUp": "browInnerUp",
	"browOuterUpLeft": "browOuterUpLeft",
	"browOuterUpRight": "browOuterUpRight",
	"cheekPuff": "cheekPuff",
	"cheekSquintLeft": "cheekSquintLeft",
	"cheekSquintRight": "cheekSquintRight",
	"eyeBlinkLeft": "eyeBlinkLeft",
	"eyeBlinkRight": "eyeBlinkRight",
	"eyeLookDownLeft": "eyeLookDownLeft",
	"eyeLookDownRight": "eyeLookDownRight",
	"eyeLookInLeft": "eyeLookInLeft",
	"eyeLookInRight": "eyeLookInRight",
	"eyeLookOutLeft": "eyeLookOutLeft",
	"eyeLookOutRight": "eyeLookOutRight",
	"eyeLookUpLeft": "eyeLookUpLeft",
	"eyeLookUpRight": "eyeLookUpRight",
	"eyeSquintLeft": "eyeSquintLeft",
	"eyeSquintRight": "eyeSquintRight",
	"eyeWideLeft": "eyeWideLeft",
	"eyeWideRight": "eyeWideRight",
	"jawForward": "jawForward",
	"jawLeft": "jawLeft",
	"jawOpen": "jawOpen",
	"jawRight": "jawRight",
	"mouthClose": "mouthClose",
	"mouthDimpleLeft": "mouthDimpleLeft",
	"mouthDimpleRight": "mouthDimpleRight",
	"mouthFrownLeft": "mouthFrownLeft",
	"mouthFrownRight": "mouthFrownRight",
	"mouthFunnel": "mouthFunnel",
	"mouthLeft": "mouthLeft",
	"mouthLowerDownLeft": "mouthLowerDownLeft",
	"mouthLowerDownRight": "mouthLowerDownRight",
	"mouthPressLeft": "mouthPressLeft",
	"mouthPressRight": "mouthPressRight",
	"mouthPucker": "mouthPucker",
	"mouthRight": "mouthRight",
	"mouthRollLower": "mouthRollLower",
	"mouthRollUpper": "mouthRollUpper",
	"mouthShrugLower": "mouthShrugLower",
	"mouthShrugUpper": "mouthShrugUpper",
	"mouthSmileLeft": "mouthSmileLeft",
	"mouthSmileRight": "mouthSmileRight",
	"mouthStretchLeft": "mouthStretchLeft",
	"mouthStretchRight": "mouthStretchRight",
	"mouthUpperUpLeft": "mouthUpperUpLeft",
	"mouthUpperUpRight": "mouthUpperUpRight",
	"noseSneerLeft": "noseSneerLeft",
	"noseSneerRight": "noseSneerRight"
}

func _ready() -> void:
	print("[FaceTracking] Initializing face tracking manager")

func initialize() -> bool:
	print("[FaceTracking] Loading model from: ", model_path)
	
	# Check if MediaPipe classes are available
	if not ClassDB.class_exists("MediaPipeFaceLandmarker"):
		push_error("[FaceTracking] MediaPipeFaceLandmarker class not found. GDMP plugin may not be loaded.")
		tracking_error.emit("GDMP plugin not available")
		return false
	
	# Load model file
	if not FileAccess.file_exists(model_path):
		push_error("[FaceTracking] Model file not found: ", model_path)
		tracking_error.emit("Face landmarker model not found")
		return false
	
	var file := FileAccess.open(model_path, FileAccess.READ)
	if file == null:
		push_error("[FaceTracking] Failed to open model file: ", model_path)
		tracking_error.emit("Failed to load face landmarker model")
		return false
	
	var model_buffer := file.get_buffer(file.get_length())
	file.close()
	
	# Create base options
	var base_options := MediaPipeTaskBaseOptions.new()
	# Note: delegate property removed in GDMP 0.6+ (uses CPU by default)
	base_options.model_asset_buffer = model_buffer
	
	# Create face landmarker
	face_landmarker = MediaPipeFaceLandmarker.new()
	var running_mode = MediaPipeTask.RunningMode.LIVE_STREAM
	# Parameters: base_options, running_mode, num_faces, min_detection_confidence, min_tracking_confidence, min_presence_confidence, output_blendshapes
	face_landmarker.initialize(base_options, running_mode, 1, 0.5, 0.5, 0.5, true)
	face_landmarker.result_callback.connect(_on_face_result)
	
	print("[FaceTracking] Face landmarker initialized successfully")
	return true

func start_tracking() -> bool:
	if face_landmarker == null:
		if not initialize():
			return false
	
	is_tracking = true
	print("[FaceTracking] Tracking started")
	return true

func stop_tracking() -> void:
	is_tracking = false
	print("[FaceTracking] Tracking stopped")

func process_frame(image: Image, timestamp_ms: int) -> void:
	if not is_tracking or face_landmarker == null:
		return
	
	var mediapipe_image := MediaPipeImage.new()
	mediapipe_image.set_image(image)
	face_landmarker.detect_async(mediapipe_image, timestamp_ms)

func _on_face_result(result: MediaPipeFaceLandmarkerResult, image: MediaPipeImage, timestamp_ms: int) -> void:
	if result:
		if result.face_landmarks.size() > 0:
			face_landmarks_updated.emit(result.face_landmarks)
		
		if result.has_face_blendshapes() and result.face_blendshapes.size() > 0:
			face_blendshapes_updated.emit(result.face_blendshapes[0])

func get_vrm_blendshapes(mediapipe_blendshapes: MediaPipeClassifications) -> Dictionary:
	# Convert MediaPipe blendshapes to VRM-compatible dictionary
	var vrm_blendshapes := {}
	
	for category in mediapipe_blendshapes.categories:
		if category.has_category_name():
			var mp_name: String = category.category_name
			if mp_name in vrm_blendshape_mapping:
				var vrm_name: String = vrm_blendshape_mapping[mp_name]
				vrm_blendshapes[vrm_name] = category.score
	
	return vrm_blendshapes
