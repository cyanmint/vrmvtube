extends Node
class_name Settings

# Settings manager for VRMVTube
# Handles loading, saving, and accessing application settings

const SETTINGS_FILE := "user://settings.json"

# Default settings
var default_settings := {
	"model": {
		"default_model_path": "res://assets/models/cyanmint.vrm",
		"auto_load": true,
		"position": {"x": 0.0, "y": 0.0, "z": 0.0},
		"rotation": {"x": 0.0, "y": 0.0, "z": 0.0}
	},
	"camera": {
		"index": 0,
		"position": {"x": 0.0, "y": 1.2, "z": 1.0},
		"rotation": {"x": -10.0, "y": 0.0, "z": 0.0},
		"fov": 75.0
	},
	"tracking": {
		"hand_tracking": true,
		"face_tracking": true
	},
	"video": {
		"resolution_width": 1280,
		"resolution_height": 720,
		"quality": "high",  # low, medium, high, ultra
		"render_scale": 1.0,  # 0.5 to 2.0 (DPI scaling)
		"msaa": "disabled",  # disabled, 2x, 4x, 8x
		"fxaa": false,
		"vsync": true,
		"max_fps": 60
	}
}

var current_settings := {}

func _ready() -> void:
	load_settings()

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_FILE):
		var file := FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		if file:
			var json_string := file.get_as_text()
			file.close()
			
			var json := JSON.new()
			var error := json.parse(json_string)
			if error == OK:
				current_settings = json.data
				print("[Settings] Loaded settings from file")
			else:
				print("[Settings] Error parsing settings file at line ", json.get_error_line(), ": ", json.get_error_message())
				current_settings = default_settings.duplicate(true)
		else:
			print("[Settings] Failed to open settings file, using defaults")
			current_settings = default_settings.duplicate(true)
	else:
		print("[Settings] Settings file not found, using defaults")
		current_settings = default_settings.duplicate(true)

func save_settings() -> void:
	var file := FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file:
		var json_string := JSON.stringify(current_settings, "\t")
		file.store_string(json_string)
		file.close()
		print("[Settings] Settings saved")
	else:
		var error := FileAccess.get_open_error()
		push_error("[Settings] Failed to save settings file. Error: ", error)
		# Could notify user here via a signal if needed

func get_setting(path: String, default_value = null):
	var keys := path.split("/")
	var current = current_settings
	
	for key in keys:
		if current is Dictionary and key in current:
			current = current[key]
		else:
			return default_value
	
	return current

func set_setting(path: String, value) -> void:
	var keys := path.split("/")
	var current = current_settings
	
	for i in range(keys.size() - 1):
		var key = keys[i]
		if not (current is Dictionary and key in current):
			current[key] = {}
		elif not current[key] is Dictionary:
			# If the intermediate value is not a dictionary, replace it
			push_warning("[Settings] Overwriting non-dictionary value at path: ", "/".join(keys.slice(0, i + 1)))
			current[key] = {}
		current = current[key]
	
	current[keys[-1]] = value

func get_model_default_path() -> String:
	return get_setting("model/default_model_path", "res://assets/models/cyanmint.vrm")

func should_auto_load_model() -> bool:
	return get_setting("model/auto_load", true)

func get_camera_index() -> int:
	return get_setting("camera/index", 0)

func get_camera_position() -> Vector3:
	var pos = get_setting("camera/position", {"x": 0.0, "y": 1.0, "z": 3.0})
	return Vector3(pos.x, pos.y, pos.z)

func get_camera_rotation() -> Vector3:
	var rot = get_setting("camera/rotation", {"x": 0.0, "y": 0.0, "z": 0.0})
	return Vector3(rot.x, rot.y, rot.z)

func get_model_position() -> Vector3:
	var pos = get_setting("model/position", {"x": 0.0, "y": 0.0, "z": 0.0})
	return Vector3(pos.x, pos.y, pos.z)

func get_model_rotation() -> Vector3:
	var rot = get_setting("model/rotation", {"x": 0.0, "y": 0.0, "z": 0.0})
	return Vector3(rot.x, rot.y, rot.z)

func set_camera_position(pos: Vector3) -> void:
	set_setting("camera/position", {"x": pos.x, "y": pos.y, "z": pos.z})

func set_camera_rotation(rot: Vector3) -> void:
	set_setting("camera/rotation", {"x": rot.x, "y": rot.y, "z": rot.z})

func set_model_position(pos: Vector3) -> void:
	set_setting("model/position", {"x": pos.x, "y": pos.y, "z": pos.z})

func set_model_rotation(rot: Vector3) -> void:
	set_setting("model/rotation", {"x": rot.x, "y": rot.y, "z": rot.z})

func set_camera_index(index: int) -> void:
	set_setting("camera/index", index)

# Video quality settings
func get_video_resolution_width() -> int:
	return get_setting("video/resolution_width", 1280)

func get_video_resolution_height() -> int:
	return get_setting("video/resolution_height", 720)

func set_video_resolution(width: int, height: int) -> void:
	set_setting("video/resolution_width", width)
	set_setting("video/resolution_height", height)

func get_video_quality() -> String:
	return get_setting("video/quality", "high")

func set_video_quality(quality: String) -> void:
	set_setting("video/quality", quality)

func get_render_scale() -> float:
	return get_setting("video/render_scale", 1.0)

func set_render_scale(scale: float) -> void:
	set_setting("video/render_scale", scale)

func get_msaa() -> String:
	return get_setting("video/msaa", "disabled")

func set_msaa(msaa: String) -> void:
	set_setting("video/msaa", msaa)

func get_fxaa() -> bool:
	return get_setting("video/fxaa", false)

func set_fxaa(enabled: bool) -> void:
	set_setting("video/fxaa", enabled)

func get_vsync() -> bool:
	return get_setting("video/vsync", true)

func set_vsync(enabled: bool) -> void:
	set_setting("video/vsync", enabled)

func get_max_fps() -> int:
	return get_setting("video/max_fps", 60)

func set_max_fps(fps: int) -> void:
	set_setting("video/max_fps", fps)
