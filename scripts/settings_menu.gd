extends Window

## Settings Menu for VRMVTube
##
## Provides a comprehensive settings dialog similar to VRigUnity
## Includes: Model selection, Background, Camera input, About page
## With Save/Cancel/Apply functionality
##
## Created by: GitHub Copilot

signal settings_applied(settings: Dictionary)
signal settings_saved(settings: Dictionary)

# Settings categories
@export var current_settings := {
	"model": {
		"path": "res://example/cyanmint.vrm",
		"recent_models": []
	},
	"background": {
		"type": "solid",  # solid, gradient, image
		"color": Color(0.2, 0.2, 0.25, 1.0),
		"gradient_top": Color(0.2, 0.2, 0.3, 1.0),
		"gradient_bottom": Color(0.1, 0.1, 0.15, 1.0),
		"image_path": ""
	},
	"camera": {
		"selected_index": 0,
		"device_name": ""
	}
}

var original_settings := {}
const CONFIG_PATH := "user://vrmvtube_settings.cfg"

# UI References
@onready var tab_container: TabContainer = $MarginContainer/VBoxContainer/TabContainer
@onready var save_button: Button = $MarginContainer/VBoxContainer/ButtonPanel/SaveButton
@onready var cancel_button: Button = $MarginContainer/VBoxContainer/ButtonPanel/CancelButton
@onready var apply_button: Button = $MarginContainer/VBoxContainer/ButtonPanel/ApplyButton

# Model Tab
@onready var model_path_label: Label = $MarginContainer/VBoxContainer/TabContainer/Model/VBoxContainer/ModelPathLabel
@onready var browse_model_button: Button = $MarginContainer/VBoxContainer/TabContainer/Model/VBoxContainer/BrowseButton
@onready var model_file_dialog: FileDialog = $ModelFileDialog

# Background Tab
@onready var bg_type_option: OptionButton = $MarginContainer/VBoxContainer/TabContainer/Background/VBoxContainer/TypeOption
@onready var bg_color_picker: ColorPickerButton = $MarginContainer/VBoxContainer/TabContainer/Background/VBoxContainer/ColorPicker
@onready var bg_gradient_top_picker: ColorPickerButton = $MarginContainer/VBoxContainer/TabContainer/Background/VBoxContainer/GradientTopPicker
@onready var bg_gradient_bottom_picker: ColorPickerButton = $MarginContainer/VBoxContainer/TabContainer/Background/VBoxContainer/GradientBottomPicker

# Camera Tab
@onready var camera_option: OptionButton = $MarginContainer/VBoxContainer/TabContainer/Camera/VBoxContainer/CameraOption
@onready var camera_info_label: Label = $MarginContainer/VBoxContainer/TabContainer/Camera/VBoxContainer/InfoLabel

# About Tab
@onready var about_text: RichTextLabel = $MarginContainer/VBoxContainer/TabContainer/About/ScrollContainer/AboutText

func _ready() -> void:
	# Load settings from file
	_load_settings()
	
	# Store original settings for cancel
	original_settings = current_settings.duplicate(true)
	
	# Setup UI
	_setup_ui()
	
	# Connect signals
	_connect_signals()
	
	# Hide by default
	hide()

func _setup_ui() -> void:
	"""Setup UI elements with current settings"""
	# Window properties
	title = "Settings"
	size = Vector2i(600, 500)
	
	# Model tab
	if model_path_label:
		model_path_label.text = current_settings.model.path
	
	# Background tab
	if bg_type_option:
		bg_type_option.clear()
		bg_type_option.add_item("Solid Color", 0)
		bg_type_option.add_item("Gradient", 1)
		bg_type_option.add_item("Image", 2)
		match current_settings.background.type:
			"solid": bg_type_option.selected = 0
			"gradient": bg_type_option.selected = 1
			"image": bg_type_option.selected = 2
	
	if bg_color_picker:
		bg_color_picker.color = current_settings.background.color
	
	if bg_gradient_top_picker:
		bg_gradient_top_picker.color = current_settings.background.gradient_top
	
	if bg_gradient_bottom_picker:
		bg_gradient_bottom_picker.color = current_settings.background.gradient_bottom
	
	# Camera tab
	_populate_cameras()
	
	# About tab
	_setup_about_text()

func _connect_signals() -> void:
	"""Connect UI signals"""
	if save_button:
		save_button.pressed.connect(_on_save_pressed)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)
	if apply_button:
		apply_button.pressed.connect(_on_apply_pressed)
	
	if browse_model_button:
		browse_model_button.pressed.connect(_on_browse_model_pressed)
	if model_file_dialog:
		model_file_dialog.file_selected.connect(_on_model_file_selected)
	
	if bg_type_option:
		bg_type_option.item_selected.connect(_on_bg_type_changed)
	if bg_color_picker:
		bg_color_picker.color_changed.connect(_on_bg_color_changed)
	if bg_gradient_top_picker:
		bg_gradient_top_picker.color_changed.connect(_on_bg_gradient_top_changed)
	if bg_gradient_bottom_picker:
		bg_gradient_bottom_picker.color_changed.connect(_on_bg_gradient_bottom_changed)
	
	if camera_option:
		camera_option.item_selected.connect(_on_camera_selected)

func _populate_cameras() -> void:
	"""Populate camera dropdown with available cameras"""
	if not camera_option:
		return
	
	camera_option.clear()
	
	# Check for available cameras
	var camera_server := CameraServer
	var feed_count := camera_server.get_feed_count()
	
	if feed_count > 0:
		for i in range(feed_count):
			var feed := camera_server.get_feed(i)
			if feed:
				camera_option.add_item(feed.get_name(), i)
		camera_option.selected = current_settings.camera.selected_index
	else:
		camera_option.add_item("No cameras detected", 0)
		camera_option.disabled = true
		if camera_info_label:
			camera_info_label.text = "Desktop webcam access is limited in Godot 4.x\nSimulated tracking is used instead"

func _setup_about_text() -> void:
	"""Setup about tab content"""
	if not about_text:
		return
	
	var about_content := """[center][b]VRMVTube[/b][/center]
[center]Cross-platform VTubing Application[/center]
[center]Version 1.0.0[/center]

[b]About[/b]
VRMVTube is a VTubing application built with Godot Engine that supports VRM avatars for real-time animation.

[b]Credits[/b]
• [b]godot-vrm[/b] (MIT License) - V-Sekai
  VRM model import and export functionality
  © 2020-2021 V-Sekai Contributors
  © 2020 VRM Consortium

• [b]MToon Shader[/b] (MIT License)
  Anime-style shader for VRM models
  © 2018 Masataka SUMI

• [b]Godot Engine[/b] (MIT License)
  Game engine and framework
  © 2007-2021 Juan Linietsky, Ariel Manzur
  © 2014-2021 Godot Engine contributors

[b]Inspiration[/b]
• [b]VRigUnity[/b] by Kariaro
  Design and feature inspiration

[b]Platform Support[/b]
• Windows, macOS, Linux (Desktop)
• Android (Mobile)
• Web (Browser)

[b]License[/b]
This project is licensed under CC0 1.0 Universal
Copyright 2025-2026 cyan mint <cyanmint@outlook.com>

[b]Links[/b]
• GitHub: https://github.com/cyanmint/vrmvtube
• VRM Specification: https://vrm.dev/
• Godot Engine: https://godotengine.org/

[b]Note[/b]
This project was created with assistance from GitHub Copilot.
AI-generated content is neither subject to copyright nor covered by warranty.
"""
	about_text.bbcode_enabled = true
	about_text.text = about_content

# Signal handlers
func _on_save_pressed() -> void:
	"""Save settings to file and apply"""
	_save_settings()
	settings_saved.emit(current_settings)
	settings_applied.emit(current_settings)
	hide()

func _on_cancel_pressed() -> void:
	"""Cancel changes and restore original settings"""
	current_settings = original_settings.duplicate(true)
	_setup_ui()
	hide()

func _on_apply_pressed() -> void:
	"""Apply settings without saving"""
	settings_applied.emit(current_settings)

func _on_browse_model_pressed() -> void:
	"""Open file dialog to select VRM model"""
	if model_file_dialog:
		model_file_dialog.popup_centered()

func _on_model_file_selected(path: String) -> void:
	"""Handle model file selection"""
	current_settings.model.path = path
	if model_path_label:
		model_path_label.text = path
	
	# Add to recent models
	if not path in current_settings.model.recent_models:
		current_settings.model.recent_models.append(path)
		if current_settings.model.recent_models.size() > 10:
			current_settings.model.recent_models.remove_at(0)

func _on_bg_type_changed(index: int) -> void:
	"""Handle background type change"""
	match index:
		0: current_settings.background.type = "solid"
		1: current_settings.background.type = "gradient"
		2: current_settings.background.type = "image"

func _on_bg_color_changed(color: Color) -> void:
	"""Handle background color change"""
	current_settings.background.color = color

func _on_bg_gradient_top_changed(color: Color) -> void:
	"""Handle gradient top color change"""
	current_settings.background.gradient_top = color

func _on_bg_gradient_bottom_changed(color: Color) -> void:
	"""Handle gradient bottom color change"""
	current_settings.background.gradient_bottom = color

func _on_camera_selected(index: int) -> void:
	"""Handle camera selection"""
	current_settings.camera.selected_index = index
	if camera_option and index >= 0 and index < camera_option.item_count:
		current_settings.camera.device_name = camera_option.get_item_text(index)

# Settings persistence
func _load_settings() -> void:
	"""Load settings from config file"""
	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)
	
	if err != OK:
		print("Settings: No config file found, using defaults")
		return
	
	# Load model settings
	if config.has_section("model"):
		current_settings.model.path = config.get_value("model", "path", current_settings.model.path)
		current_settings.model.recent_models = config.get_value("model", "recent_models", [])
	
	# Load background settings
	if config.has_section("background"):
		current_settings.background.type = config.get_value("background", "type", "solid")
		
		# Load colors (convert from array to Color)
		var color_array = config.get_value("background", "color", [0.2, 0.2, 0.25, 1.0])
		current_settings.background.color = Color(color_array[0], color_array[1], color_array[2], color_array[3])
		
		var gt_array = config.get_value("background", "gradient_top", [0.2, 0.2, 0.3, 1.0])
		current_settings.background.gradient_top = Color(gt_array[0], gt_array[1], gt_array[2], gt_array[3])
		
		var gb_array = config.get_value("background", "gradient_bottom", [0.1, 0.1, 0.15, 1.0])
		current_settings.background.gradient_bottom = Color(gb_array[0], gb_array[1], gb_array[2], gb_array[3])
		
		current_settings.background.image_path = config.get_value("background", "image_path", "")
	
	# Load camera settings
	if config.has_section("camera"):
		current_settings.camera.selected_index = config.get_value("camera", "selected_index", 0)
		current_settings.camera.device_name = config.get_value("camera", "device_name", "")
	
	print("Settings: Loaded from ", CONFIG_PATH)

func _save_settings() -> void:
	"""Save settings to config file"""
	var config := ConfigFile.new()
	
	# Save model settings
	config.set_value("model", "path", current_settings.model.path)
	config.set_value("model", "recent_models", current_settings.model.recent_models)
	
	# Save background settings (convert Color to array for serialization)
	config.set_value("background", "type", current_settings.background.type)
	var color := current_settings.background.color
	config.set_value("background", "color", [color.r, color.g, color.b, color.a])
	var gt := current_settings.background.gradient_top
	config.set_value("background", "gradient_top", [gt.r, gt.g, gt.b, gt.a])
	var gb := current_settings.background.gradient_bottom
	config.set_value("background", "gradient_bottom", [gb.r, gb.g, gb.b, gb.a])
	config.set_value("background", "image_path", current_settings.background.image_path)
	
	# Save camera settings
	config.set_value("camera", "selected_index", current_settings.camera.selected_index)
	config.set_value("camera", "device_name", current_settings.camera.device_name)
	
	var err := config.save(CONFIG_PATH)
	if err == OK:
		print("Settings: Saved to ", CONFIG_PATH)
	else:
		push_error("Settings: Failed to save to ", CONFIG_PATH)

func show_settings() -> void:
	"""Show the settings window"""
	# Reload original settings when opening
	original_settings = current_settings.duplicate(true)
	_setup_ui()
	popup_centered()
