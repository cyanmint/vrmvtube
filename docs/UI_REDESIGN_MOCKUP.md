# VRMVTube UI Redesign - Visual Mockup

## Overview

This document shows the visual transformation of VRMVTube from the old design to the new HUD overlay design.

## Before: Old Design

```
┌──────────────────────────────────────────────────────────────┐
│                         VRMVTube                             │
│                                                              │
│  VTuber Application with VRM and MediaPipe Support          │
│              Powered by Godot Engine 4.6                    │
│                                                              │
│        [Load VRM Model]  [Start Tracking]                   │
│                                                              │
│                    Status: Ready                            │
├──────────────────────┬──────────────┬──────────────────────┤
│                      │              │  Settings         ◀  │
│                      │              ├──────────────────────┤
│                      │   Camera     │  [Mode: Move]        │
│   3D Viewport        │   Preview    │                      │
│   (VRM Model)        │   (320x240)  │  Camera Controls     │
│                      │              │  Position: X Y Z     │
│                      │              │  Rotation: X Y Z     │
│                      │              │                      │
│                      │              │  Model Transform     │
│                      │              │  Position: X Y Z     │
│                      │              │  Rotation: X Y Z     │
│                      │              │                      │
└──────────────────────┴──────────────┴──────────────────────┘
```

**Problems:**
- Title and buttons take up vertical space
- Status bar is separate from controls
- Camera preview is in the middle, between viewport and HUD
- Settings panel is on the right but doesn't include all UI elements

## After: New HUD Overlay Design

```
┌──────────────────────────────────┬───────────────────────────┐
│                                  │ VRMVTube              ◀  │
│                                  ├───────────────────────────┤
│                                  │ ▼ Scrollable Content ▼   │
│                                  │                           │
│                                  │ VTuber Application with   │
│                                  │ VRM and MediaPipe Support │
│                                  │ Powered by Godot 4.6      │
│                                  │ ──────────────────────   │
│                                  │                           │
│                                  │ Model Management          │
│      3D Viewport                 │ [Load VRM Model]          │
│                                  │ ──────────────────────   │
│   GREEN BACKGROUND               │                           │
│   (#00FF00)                      │ Tracking Controls         │
│                                  │ [Start Tracking]          │
│   VRM Model Display Only         │                           │
│                                  │ ┌──────────────────────┐ │
│   (Clean view like VRigUnity)    │ │  Camera Preview      │ │
│                                  │ │  (320x240)           │ │
│                                  │ └──────────────────────┘ │
│                                  │ ──────────────────────   │
│                                  │                           │
│                                  │ Settings                  │
│                                  │ [Mode: Move]              │
│                                  │                           │
│                                  │ Camera Controls           │
│                                  │ Position: X Y Z           │
│                                  │ Rotation: X Y Z           │
│                                  │                           │
│                                  │ Model Transform           │
│                                  │ Position: X Y Z           │
│                                  │ Rotation: X Y Z           │
│                                  │ ──────────────────────   │
│                                  │                           │
│                                  │ Status: Ready             │
│                                  │                           │
└──────────────────────────────────┴───────────────────────────┘
       Full-screen viewport           Scrollable HUD (400px)
```

## Key Changes

### 1. Clean Viewport
- **Full-screen 3D viewport** - No UI elements blocking the view
- **Green chroma key background** (#00FF00) for easy removal in OBS/streaming software
- **Just the model** - Clean presentation like VRigUnity
- Takes up maximum space (left side grows to fill available width)

### 2. Consolidated HUD Overlay
- **All UI moved to right panel** - Product info, buttons, camera, settings, status
- **Scrollable** - Entire HUD content scrolls up/down
- **Foldable** - Collapse button (◀/▶) to hide/show content
- **Organized sections:**
  - Header with title and collapse button
  - Product info (app description)
  - Model Management (Load VRM button)
  - Tracking Controls (Start Tracking button + camera preview)
  - Settings (camera/model controls)
  - Status (status messages)

### 3. HUD Panel States

**Expanded State (400px):**
```
┌─────────────────────────┐
│ VRMVTube            ◀  │
├─────────────────────────┤
│ [All content visible]   │
│ [Scrollable]            │
│ [Everything accessible] │
└─────────────────────────┘
```

**Collapsed State (50px):**
```
┌──┐
│V ▶│
│R  │
│M  │
│V  │
│T  │
│u  │
│b  │
│e  │
│   │
└──┘
```

## Color Scheme

### Viewport Background
- **Color:** Pure Green (#00FF00 / RGB 0, 255, 0)
- **Purpose:** Chroma key green for easy background removal
- **Implementation:** Environment.BG_COLOR mode in WorldEnvironment

### HUD Panel
- **Background:** PanelContainer with default theme (gray)
- **Text:** Default theme colors
- **Buttons:** Standard Godot button styling

## Layout Hierarchy

```
Main (Control)
└── ContentContainer (HBoxContainer - fills screen)
    ├── ViewportContainer (expands to fill left)
    │   └── SubViewport
    │       ├── WorldEnvironment (green background)
    │       ├── Camera3D
    │       ├── DirectionalLight3D
    │       └── VRMModel
    │
    └── HUDOverlay (PanelContainer - 400px/50px wide)
        └── VBoxContainer
            ├── Header (HBoxContainer)
            │   ├── TitleLabel ("VRMVTube")
            │   └── CollapseButton ("◀"/"▶")
            │
            └── ScrollContainer (up/down scrolling)
                └── ContentVBox
                    ├── InfoSection (app description)
                    ├── ModelSection (Load VRM button)
                    ├── TrackingSection (button + camera preview)
                    ├── SettingsSection (ControlPanel)
                    └── StatusSection (status label)
```

## Responsive Behavior

### Desktop (1920x1080)
- Viewport: ~1500px wide
- HUD: 400px wide (expanded) or 50px (collapsed)
- Vertical scrolling available for HUD content

### Mobile/Portrait (720x1280)
- Viewport: Stacks or fills based on orientation
- HUD: Still scrollable and foldable
- Green background optimized for vertical capture

### Collapsed Mode
- Viewport: Gains 350px more width
- HUD: Shows only vertical "VRMVTube" text
- Quick expand with button click

## Use Cases

### 1. VTubing / Streaming
```
┌──────────────────────────┐
│                          │  Green background removed
│    VRM Model Only        │  Model overlaid on game/content
│                          │  HUD collapsed for maximum space
│                          │
└──────────────────────────┘
```

### 2. Setup / Configuration
```
┌────────────┬────────────┐
│            │ HUD        │  HUD expanded for access to all controls
│  Viewport  │ [Controls] │  Adjust camera, model, tracking
│            │ [Settings] │  See changes in real-time
│            │            │
└────────────┴────────────┘
```

### 3. Testing / Debugging
```
┌────────────┬────────────┐
│  Green BG  │ Status:... │  Green background visible
│  + Model   │ Camera:... │  Full diagnostic info in HUD
│            │ [Preview]  │  Camera preview for tracking check
│            │            │
└────────────┴────────────┘
```

## Comparison to VRigUnity

VRigUnity Screenshot (conceptual):
```
┌──────────────────────────┬───────────┐
│                          │  Panel    │
│   Green Screen           │           │
│   + VRM Model            │  Controls │
│                          │           │
└──────────────────────────┴───────────┘
```

VRMVTube (matches this design):
```
┌──────────────────────────┬───────────┐
│                          │  HUD      │
│   Green Screen           │           │
│   + VRM Model            │  Controls │
│                          │  (scroll) │
└──────────────────────────┴───────────┘
```

**Similarities:**
- Clean viewport with just model
- Green chroma key background
- Controls/settings in side panel
- Optimized for streaming/VTubing

**VRMVTube Advantages:**
- All UI in one scrollable panel
- Collapsible for more space
- Organized into logical sections
- Status updates in HUD
- Camera preview in HUD

## Technical Implementation

### Green Background
```gdscript
# In setup_viewport() function
var world_env = viewport.get_node_or_null("WorldEnvironment")
if world_env:
    var environment = Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.0, 1.0, 0.0)  # #00FF00
    world_env.environment = environment
```

### HUD Structure
```gdscript
# Node paths updated in setup_ui_references()
status_label = get_node("ContentContainer/HUDOverlay/.../StatusLabel")
viewport_container = get_node("ContentContainer/ViewportContainer")
camera_preview = get_node("ContentContainer/HUDOverlay/.../CameraPreview")
settings_hud = get_node("ContentContainer/HUDOverlay")
```

### Collapse Functionality
```gdscript
func _on_collapse_button_pressed():
    is_settings_collapsed = !is_settings_collapsed
    if is_settings_collapsed:
        settings_scroll_container.visible = false
        collapse_button.text = "▶"
        settings_hud.custom_minimum_size = Vector2(50, 0)
    else:
        settings_scroll_container.visible = true
        collapse_button.text = "◀"
        settings_hud.custom_minimum_size = Vector2(400, 0)
```

## Summary

The new design transforms VRMVTube into a professional VTubing application:

✅ **Clean viewport** - Just model on green background
✅ **All UI in HUD** - Product info, buttons, camera, settings, status
✅ **Scrollable** - Vertical scrolling in HUD panel
✅ **Foldable** - Collapse to save space
✅ **VRigUnity-style** - Optimized for streaming
✅ **Green chroma key** - Easy background removal

Perfect for live streaming, recording, and VTuber applications!
