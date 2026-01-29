extends Node

## Python Process Manager for VRMVTube
##
## Manages Python tracking processes (MediaPipe, OpenSeeFace)
## Automatically starts/stops Python scripts based on settings
##
## Created by: GitHub Copilot

signal process_started(script_name: String)
signal process_stopped(script_name: String)
signal process_error(script_name: String, error: String)

enum PythonScript {
	MEDIAPIPE,
	OPENSEEFACE
}

const SCRIPT_PATHS := {
	PythonScript.MEDIAPIPE: "tools/mediapipe_bridge.py",
	PythonScript.OPENSEEFACE: "facetracker.py"  # OpenSeeFace path
}

var active_processes := {}
var python_executable := "python"

func _ready() -> void:
	_detect_python()

func _detect_python() -> void:
	"""Detect Python executable"""
	var platform := OS.get_name()
	
	# Try different Python executables
	var python_variants := ["python3", "python", "py"]
	
	for variant in python_variants:
		var test_output := []
		var exit_code := OS.execute(variant, ["--version"], test_output)
		if exit_code == 0:
			python_executable = variant
			print("PythonManager: Found Python: ", variant, " - ", test_output[0] if test_output.size() > 0 else "")
			return
	
	push_warning("PythonManager: Python not found in PATH")
	python_executable = ""

func start_script(script_type: PythonScript, args: Array = []) -> bool:
	"""Start a Python tracking script"""
	if python_executable == "":
		push_error("PythonManager: Python not available")
		process_error.emit(get_script_name(script_type), "Python not found")
		return false
	
	if active_processes.has(script_type):
		print("PythonManager: Script already running: ", get_script_name(script_type))
		return true
	
	var script_path := SCRIPT_PATHS.get(script_type, "")
	if script_path == "":
		push_error("PythonManager: Unknown script type")
		return false
	
	# Get absolute path
	var abs_path := ProjectSettings.globalize_path("res://" + script_path)
	
	# Check if script exists
	if not FileAccess.file_exists(abs_path):
		var error := "Script not found: " + abs_path
		push_error("PythonManager: " + error)
		process_error.emit(get_script_name(script_type), error)
		return false
	
	# Build command
	var full_args := [abs_path] + args
	
	print("PythonManager: Starting ", get_script_name(script_type))
	print("PythonManager: Command: ", python_executable, " ", full_args)
	
	# Start process using OS.create_process (non-blocking)
	var pid := OS.create_process(python_executable, full_args)
	
	if pid > 0:
		active_processes[script_type] = {
			"pid": pid,
			"script_path": script_path,
			"start_time": Time.get_ticks_msec() / 1000.0
		}
		process_started.emit(get_script_name(script_type))
		print("PythonManager: Started with PID: ", pid)
		return true
	else:
		var error := "Failed to start process"
		push_error("PythonManager: " + error)
		process_error.emit(get_script_name(script_type), error)
		return false

func stop_script(script_type: PythonScript) -> bool:
	"""Stop a Python tracking script"""
	if not active_processes.has(script_type):
		print("PythonManager: Script not running: ", get_script_name(script_type))
		return false
	
	var process_info = active_processes[script_type]
	var pid: int = process_info.pid
	
	print("PythonManager: Stopping ", get_script_name(script_type), " (PID: ", pid, ")")
	
	# Kill the process
	OS.kill(pid)
	
	active_processes.erase(script_type)
	process_stopped.emit(get_script_name(script_type))
	
	return true

func stop_all_scripts() -> void:
	"""Stop all running Python scripts"""
	for script_type in active_processes.keys():
		stop_script(script_type)

func is_script_running(script_type: PythonScript) -> bool:
	"""Check if a script is currently running"""
	return active_processes.has(script_type)

func get_script_name(script_type: PythonScript) -> String:
	"""Get human-readable script name"""
	match script_type:
		PythonScript.MEDIAPIPE:
			return "MediaPipe Bridge"
		PythonScript.OPENSEEFACE:
			return "OpenSeeFace"
		_:
			return "Unknown"

func get_running_scripts() -> Array:
	"""Get list of currently running scripts"""
	var running := []
	for script_type in active_processes.keys():
		running.append(get_script_name(script_type))
	return running

func get_status() -> Dictionary:
	"""Get Python manager status"""
	return {
		"python_available": python_executable != "",
		"python_executable": python_executable,
		"running_scripts": get_running_scripts(),
		"active_count": active_processes.size()
	}

func _exit_tree() -> void:
	"""Cleanup: stop all Python processes"""
	print("PythonManager: Shutting down, stopping all Python processes")
	stop_all_scripts()
