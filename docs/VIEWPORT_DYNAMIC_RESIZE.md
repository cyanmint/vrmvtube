# Viewport Dynamic Resizing Without Aspect Ratio Preservation

## Overview

This document describes the implementation of dynamic viewport resizing that ensures the 3D viewport properly adapts to window size changes without preserving aspect ratio. The viewport will stretch to fill the available container space, whether in portrait or landscape mode.

## Problem Statement

The viewport needed to:
1. Change dynamically with window resize events
2. Work correctly in both portrait and landscape orientations (especially Android)
3. **NOT preserve aspect ratio** - should fill the available space completely

## Solution

### Three-Part Implementation

#### 1. Window Resize Signal Handling (scripts/main.gd)

Added signal connection to monitor window size changes:

```gdscript
func _ready():
    # ... existing code ...
    
    # Connect to window resize signal to update viewport
    get_tree().root.size_changed.connect(_on_window_size_changed)
    
    # ... rest of setup ...
```

**Signal Handler:**
```gdscript
func _on_window_size_changed() -> void:
    # Update SubViewport size when window is resized
    # This ensures the viewport properly adapts to portrait/landscape changes
    _update_viewport_size()
```

**Viewport Update Function:**
```gdscript
func _update_viewport_size() -> void:
    # Update the SubViewport to match the container size
    # This is necessary for proper aspect ratio handling in portrait/landscape modes
    if viewport_container and viewport:
        var container_size = viewport_container.size
        if container_size.x > 0 and container_size.y > 0:
            viewport.size = Vector2i(int(container_size.x), int(container_size.y))
            print("[Main] Viewport resized to: ", viewport.size)
```

#### 2. Project Stretch Settings (project.godot)

Configured window stretch mode to expand without preserving aspect ratio:

```ini
[display]
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"  # <-- Key setting: No aspect ratio preservation
window/handheld/orientation=1    # Portrait mode for Android
```

**Stretch Aspect Options:**
- `"ignore"` - No stretching, black bars appear
- `"keep"` - Maintains aspect ratio with letterboxing
- `"keep_width"` - Maintains width, adjusts height
- `"keep_height"` - Maintains height, adjusts width
- **`"expand"`** - **Used here: Expands to fill without maintaining aspect ratio**

#### 3. ViewportContainer Configuration (scenes/main.tscn)

Set SubViewportContainer to stretch and fill:

```gdscript
[node name="ViewportContainer" type="SubViewportContainer"]
layout_mode = 2
size_flags_horizontal = 3  # Expand to fill horizontally
size_flags_vertical = 3    # Expand to fill vertically
stretch = true             # Enable stretching
stretch_shrink = 1         # No shrinking, 1:1 scale
```

## How It Works

### Initial Setup
1. When the application starts, `_ready()` is called
2. The viewport is set up via `setup_viewport()`
3. `_update_viewport_size()` is called to set initial size
4. Signal connection is established for future resize events

### On Window Resize
1. User resizes window (or device orientation changes on Android)
2. Godot's root viewport emits `size_changed` signal
3. `_on_window_size_changed()` is triggered
4. `_update_viewport_size()` reads the container's new size
5. SubViewport's size is updated to match container exactly
6. Viewport content stretches to fill the new dimensions

### Aspect Ratio Behavior
- **No preservation**: The viewport will stretch/squash to fill available space
- **Portrait mode**: Viewport becomes tall and narrow
- **Landscape mode**: Viewport becomes wide and short
- **Any size**: Viewport adapts to whatever dimensions the container has

## Testing

### Desktop Testing
```bash
# Run the application
./Godot_v4.6-stable_linux.x86_64 --path .

# Resize window to different dimensions:
# - Wide landscape (1920x1080)
# - Portrait (720x1280)
# - Square (1000x1000)

# Expected: Viewport fills each size without black bars
```

### Android Testing
```bash
# Build for Android
# Install on device
# Rotate device between portrait and landscape

# Expected:
# - Portrait: Viewport fills tall screen
# - Landscape: Viewport fills wide screen
# - No letterboxing or pillarboxing
```

### Verification Points
✅ No black bars appear when resizing
✅ 3D content stretches to fill entire viewport
✅ Viewport size matches container size exactly
✅ Works in both portrait and landscape
✅ Console shows resize messages: "[Main] Viewport resized to: ..."

## Code Flow Diagram

```
Window Resize Event
        ↓
Root Viewport emits size_changed signal
        ↓
_on_window_size_changed() called
        ↓
_update_viewport_size() called
        ↓
Read viewport_container.size
        ↓
Set viewport.size = container.size
        ↓
3D viewport stretches to new dimensions
        ↓
Content renders at new aspect ratio
```

## Android Portrait Mode

The configuration ensures Android devices start and stay in portrait:

**project.godot:**
```ini
window/handheld/orientation=1  # 1 = Portrait
```

**export_presets.cfg:**
```ini
screen/orientation=1  # Portrait for Android export
```

This means:
- Android app always launches in portrait
- Viewport is tall (e.g., 1080x1920)
- Content stretches to fill vertical space
- No aspect ratio preservation

## Key Differences from Aspect-Preserving Approach

### With Aspect Ratio Preservation (NOT implemented):
```
┌─────────────────┐
│                 │ ← Black bars
├─────────────────┤
│                 │
│   3D Viewport   │ ← Content maintains ratio
│   (preserved)   │
│                 │
├─────────────────┤
│                 │ ← Black bars
└─────────────────┘
```

### Without Aspect Ratio Preservation (CURRENT implementation):
```
┌─────────────────┐
│                 │
│   3D Viewport   │ ← Content stretches
│   (stretched)   │    to fill completely
│                 │
└─────────────────┘
```

## Benefits

1. **Maximum Screen Usage**: No wasted space with black bars
2. **Responsive**: Adapts to any window size or orientation
3. **Simple**: Content always fills available space
4. **Mobile-Friendly**: Works perfectly with portrait Android devices

## Trade-offs

1. **Distortion**: 3D content may appear stretched/squashed
2. **No Fixed Ratio**: UI elements may appear at different proportions
3. **Requires Flexible Design**: 3D models should look acceptable at various aspect ratios

## Recommendations for 3D Content

To work well with dynamic resizing without aspect ratio:

1. **Use Symmetric Models**: VRM characters that look good both tall and wide
2. **Flexible Camera FOV**: Adjust camera field of view if needed
3. **Test Multiple Ratios**: Verify appearance in portrait, landscape, and square viewports
4. **UI Anchoring**: Use proper anchoring for any 2D UI overlays

## Related Files

- `scripts/main.gd` - Main logic with resize handling
- `project.godot` - Window stretch configuration
- `scenes/main.tscn` - ViewportContainer setup
- `export_presets.cfg` - Android orientation settings

## References

- [Godot SubViewport Documentation](https://docs.godotengine.org/en/stable/classes/class_subviewport.html)
- [Godot Multiple Resolutions Guide](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)
- [Godot Window Stretch Modes](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html#stretch-settings)
