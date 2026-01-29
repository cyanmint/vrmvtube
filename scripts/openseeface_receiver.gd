extends Node

## OpenSeeFace Receiver for VRMVTube
##
## Receives face tracking data from OpenSeeFace via UDP
## OpenSeeFace is a free, high-accuracy face tracking solution
##
## Default port: 11573
## GitHub: https://github.com/emilianavt/OpenSeeFace
##
## Created by: GitHub Copilot

signal tracking_data_received(data: Dictionary)
signal openseeface_available_changed(available: bool)

const DEFAULT_PORT := 11573

@export var enabled: bool = true
@export var port: int = DEFAULT_PORT
@export var smooth_factor: float = 0.3

var udp := PacketPeerUDP.new()
var is_bound: bool = false
var last_packet_time: float = 0.0
var total_packets: int = 0

# Smoothed tracking data
var smoothed_rotation := Vector3.ZERO
var smoothed_position := Vector3.ZERO
var smoothed_blink_l := 0.0
var smoothed_blink_r := 0.0
var smoothed_mouth := 0.0

func _ready() -> void:
	if enabled:
		_bind_port()

func _bind_port() -> void:
	"""Bind to OpenSeeFace port"""
	var err := udp.bind(port)
	if err != OK:
		push_error("OpenSeeFaceReceiver: Failed to bind to port %d (error %d)" % [port, err])
		is_bound = false
	else:
		print("OpenSeeFaceReceiver: Listening on port %d" % port)
		print("OpenSeeFaceReceiver: Run OpenSeeFace facetracker.py to start tracking")
		is_bound = true
		openseeface_available_changed.emit(true)

func _process(_delta: float) -> void:
	if not is_bound or not enabled:
		return
	
	# Process all available packets
	var packets_processed := 0
	while udp.get_available_packet_count() > 0 and packets_processed < 10:
		var packet := udp.get_packet()
		_process_packet(packet)
		packets_processed += 1

func _process_packet(packet: PackedByteArray) -> void:
	"""Process OpenSeeFace UDP packet"""
	var packet_str := packet.get_string_from_utf8()
	var lines := packet_str.split("\n", false)
	
	for line in lines:
		var data := _parse_openseeface_line(line)
		if data != null:
			total_packets += 1
			last_packet_time = Time.get_ticks_msec() / 1000.0
			
			# Smooth the data
			_smooth_tracking_data(data)
			
			# Emit tracking data
			tracking_data_received.emit(data)

func _parse_openseeface_line(line: String) -> Dictionary:
	"""Parse a single OpenSeeFace data line
	
	Format (space-separated):
	frame_id face_id time success rx ry rz px py pz 
	[68 landmark pairs x,y] [eye_l eye_r] [eyebrow features] 
	[mouth features] [gaze vectors] [3D landmarks] ...
	"""
	var parts := line.split(" ", false)
	
	# Minimum fields: frame, id, time, success, rotation(3), position(3)
	if parts.size() < 10:
		return {}
	
	var success := int(parts[3])
	if success == 0:
		return {}  # No face detected
	
	# Parse basic data
	var data := {
		"frame_id": int(parts[0]),
		"face_id": int(parts[1]),
		"time": float(parts[2]),
		"success": success > 0,
		"raw_rotation": Vector3(float(parts[4]), float(parts[5]), float(parts[6])),
		"raw_position": Vector3(float(parts[7]), float(parts[8]), float(parts[9]))
	}
	
	# Parse landmarks if available (starts at index 10, 68 pairs = 136 values)
	var landmark_start := 10
	var num_landmarks := 68
	
	if parts.size() >= landmark_start + (num_landmarks * 2):
		var landmarks := []
		for i in range(num_landmarks):
			var idx := landmark_start + (i * 2)
			landmarks.append(Vector2(float(parts[idx]), float(parts[idx + 1])))
		data["landmarks"] = landmarks
		
		# Calculate tracking from landmarks
		_calculate_expressions_from_landmarks(data, landmarks)
	
	return data

func _calculate_expressions_from_landmarks(data: Dictionary, landmarks: Array) -> void:
	"""Calculate facial expressions from 68-point landmarks"""
	# Eye landmarks: left (36-41), right (42-47)
	# Mouth landmarks: (48-67)
	
	# Left eye aspect ratio
	if landmarks.size() >= 48:
		var left_eye_height := (landmarks[37].distance_to(landmarks[41]) + 
		                        landmarks[38].distance_to(landmarks[40])) / 2.0
		var left_eye_width := landmarks[36].distance_to(landmarks[39])
		var left_ear := left_eye_height / (left_eye_width + 0.001)
		data["eye_left_open"] = clamp(left_ear * 4.0, 0.0, 1.0)
		
		# Right eye aspect ratio
		var right_eye_height := (landmarks[43].distance_to(landmarks[47]) + 
		                         landmarks[44].distance_to(landmarks[46])) / 2.0
		var right_eye_width := landmarks[42].distance_to(landmarks[45])
		var right_ear := right_eye_height / (right_eye_width + 0.001)
		data["eye_right_open"] = clamp(right_ear * 4.0, 0.0, 1.0)
		
		# Blink is inverse of eye open
		data["blink_left"] = 1.0 - data["eye_left_open"]
		data["blink_right"] = 1.0 - data["eye_right_open"]
	
	# Mouth open (distance between upper and lower lip)
	if landmarks.size() >= 68:
		var mouth_height := (landmarks[51].distance_to(landmarks[57]) + 
		                     landmarks[62].distance_to(landmarks[66])) / 2.0
		var mouth_width := landmarks[48].distance_to(landmarks[54])
		var mouth_ratio := mouth_height / (mouth_width + 0.001)
		data["mouth_open"] = clamp(mouth_ratio * 2.0, 0.0, 1.0)
		
		# Smile detection (mouth corners up)
		var mouth_center_y := (landmarks[51].y + landmarks[57].y) / 2.0
		var corner_left_y := landmarks[48].y
		var corner_right_y := landmarks[54].y
		var smile_amount := (mouth_center_y - (corner_left_y + corner_right_y) / 2.0) / 10.0
		data["smile"] = clamp(smile_amount, 0.0, 1.0)

func _smooth_tracking_data(data: Dictionary) -> void:
	"""Apply smoothing to tracking data"""
	if data.has("raw_rotation"):
		smoothed_rotation = smoothed_rotation.lerp(data.raw_rotation, smooth_factor)
		data["head_rotation"] = smoothed_rotation
	
	if data.has("raw_position"):
		smoothed_position = smoothed_position.lerp(data.raw_position, smooth_factor)
		data["head_position"] = smoothed_position
	
	if data.has("blink_left"):
		smoothed_blink_l = lerp(smoothed_blink_l, data.blink_left, smooth_factor)
		data["blink_left"] = smoothed_blink_l
	
	if data.has("blink_right"):
		smoothed_blink_r = lerp(smoothed_blink_r, data.blink_right, smooth_factor)
		data["blink_right"] = smoothed_blink_r
	
	if data.has("mouth_open"):
		smoothed_mouth = lerp(smoothed_mouth, data.mouth_open, smooth_factor)
		data["mouth_open"] = smoothed_mouth
	
	# Add quality indicator
	data["tracking_quality"] = 1.0 if data.get("success", false) else 0.0
	data["source"] = "openseeface"

func get_status() -> Dictionary:
	"""Get receiver status"""
	var current_time := Time.get_ticks_msec() / 1000.0
	var time_since_packet := current_time - last_packet_time
	
	return {
		"is_bound": is_bound,
		"port": port,
		"enabled": enabled,
		"total_packets": total_packets,
		"time_since_last_packet": time_since_packet,
		"is_receiving": time_since_packet < 1.0
	}

func set_enabled(value: bool) -> void:
	"""Enable or disable receiver"""
	enabled = value
	if enabled and not is_bound:
		_bind_port()
	elif not enabled:
		openseeface_available_changed.emit(false)

func _exit_tree() -> void:
	"""Cleanup"""
	udp.close()
	print("OpenSeeFaceReceiver: Closed")
