# Viewport Resizing, Android Portrait Mode, and Settings Sizing Implementation

## Overview

This document describes the implementation of responsive viewport resizing, Android portrait mode configuration, and proper settings popup sizing based on Godot 4.6 best practices.

## Changes Implemented

### 1. Viewport Resizing with Window Size

**Problem**: The 3D viewport (SubViewport) had a fixed size and did not resize when the window was resized.

**Solution**: According to Godot documentation, `SubViewportContainer.stretch` property controls whether the SubViewport automatically resizes to fill the container.

**Implementation**:
```gdscript
# scenes/main.tscn
[node name="ViewportContainer" type="SubViewportContainer" parent="VBoxContainer/ContentContainer"]
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 3
stretch = true  # <-- Added this property
```

**Behavior**:
- When `stretch = true`, the SubViewportContainer automatically resizes the SubViewport to fill available space
- The SubViewport size is now controlled by the container and adapts to window size changes
- Manual size setting is disabled when stretch is enabled (as per Godot docs)

**Reference**: [Godot SubViewport Documentation](https://docs.godotengine.org/en/stable/classes/class_subviewport.html)

### 2. Android Portrait Mode

**Problem**: Android app needed to start in portrait orientation by default.

**Solution**: Godot 4.6 provides two ways to set orientation:
1. Project-wide setting in `project.godot`
2. Platform-specific setting in export presets

**Implementation**:

#### Project Settings (`project.godot`):
```ini
[display]
window/handheld/orientation=1
```

Orientation values:
- 0 = Landscape
- 1 = Portrait (implemented)
- 2 = Reverse Landscape
- 3 = Reverse Portrait
- 4 = Sensor Landscape
- 5 = Sensor Portrait
- 6 = Sensor

#### Android Export Preset (`export_presets.cfg`):
```ini
[preset.4.options]
screen/orientation=1  # Portrait
```

**Benefits**:
- App always starts in portrait mode on Android devices
- Consistent orientation across all Android devices
- Follows Android Material Design guidelines for VTuber apps

**Reference**: [Godot Exporting for Android Documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)

### 3. Settings Popup Size Constraints

**Problem**: Settings popup was too large (800x400) and could overflow on smaller screens.

**Solution**: Use proper size constraints and ScrollContainer for overflow content.

**Implementation**:

#### Window Size Constraints:
```gdscript
# scenes/main.tscn
[node name="SettingsPopup" type="Window" parent="."]
title = "Settings"
initial_position = 2
size = Vector2i(600, 350)      # Reduced from 800x400
min_size = Vector2i(400, 250)  # Minimum window size
max_size = Vector2i(900, 600)  # Maximum window size
visible = false
```

#### ScrollContainer for Overflow:
```gdscript
[node name="ScrollContainer" type="ScrollContainer" parent="SettingsPopup"]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="ControlPanel" type="PanelContainer" parent="SettingsPopup/ScrollContainer"]
layout_mode = 2
size_flags_horizontal = 3
```

**Benefits**:
- Settings popup fits on smaller screens (e.g., mobile devices)
- Scrollbars appear automatically when content exceeds window size
- Window can be resized by user within min/max constraints
- Better UX on portrait-oriented devices

**Code Changes**:
- Updated `main.gd` to reference the new path: `"SettingsPopup/ScrollContainer/ControlPanel"`
- All child nodes updated to reflect ScrollContainer in hierarchy

**Reference**: [Godot ScrollContainer Documentation](https://docs.godotengine.org/en/stable/classes/class_scrollcontainer.html)

## Testing

### Compilation Test
```bash
./Godot_v4.6-stable_linux.x86_64 --headless --check-only --path .
```
**Result**: ✅ No syntax errors

### Runtime Test
```bash
./Godot_v4.6-stable_linux.x86_64 --headless --path . --quit
```
**Result**: ✅ No warnings, application runs successfully

### Expected Behavior

#### Desktop:
- Window is resizable
- Viewport scales automatically with window size
- Settings popup appears centered with proper size constraints
- ScrollContainer shows scrollbars if needed

#### Android:
- App starts in portrait orientation
- Screen rotation locked to portrait
- Settings popup fits within portrait screen bounds
- Scrollable content works with touch gestures

## Files Modified

1. **scenes/main.tscn**
   - Added `stretch = true` to ViewportContainer
   - Changed SettingsPopup size from 800x400 to 600x350
   - Added min_size and max_size constraints to SettingsPopup
   - Added ScrollContainer as parent of ControlPanel
   - Updated all node paths to include ScrollContainer

2. **project.godot**
   - Added `window/handheld/orientation=1` for portrait mode

3. **export_presets.cfg**
   - Added `screen/orientation=1` to Android export preset

4. **scripts/main.gd**
   - Updated control_panel path reference to `"SettingsPopup/ScrollContainer/ControlPanel"`

## Technical Notes

### SubViewportContainer Stretch Behavior
According to Godot documentation:
> "If the parent node is a SubViewportContainer and its SubViewportContainer.stretch is true, the viewport size cannot be changed manually."

This means:
- The SubViewport size automatically matches the container size
- Manual `set_size()` calls are ineffective when stretch is enabled
- For custom scaling, use `size_2d_override` properties (advanced use case)

### ScrollContainer Best Practices
From Godot documentation:
- ScrollContainer only shows scrollbars if content's minimum size exceeds its own size
- Child nodes should use `layout_mode = 2` for proper container behavior
- Use `custom_minimum_size` on child content if needed to enforce scrollable area

### Android Orientation Locking
The orientation setting:
- Prevents accidental rotation to landscape
- Optimizes UI layout for portrait viewing
- Consistent with VTuber app conventions (vertical camera feed)

## Future Enhancements

1. **Dynamic Viewport Scaling**
   - Add render scale option for performance on mobile
   - Implement quality presets (Low/Medium/High)

2. **Responsive Settings Layout**
   - Adapt settings layout for narrow screens
   - Stack controls vertically on small displays

3. **Orientation Options**
   - Add user setting to allow landscape mode
   - Implement auto-rotation based on device sensor

4. **Window Memory**
   - Save and restore settings popup size/position
   - Remember user's preferred window dimensions

## References

- [Godot SubViewport Class](https://docs.godotengine.org/en/stable/classes/class_subviewport.html)
- [Godot SubViewportContainer Class](https://docs.godotengine.org/en/stable/classes/class_subviewportcontainer.html)
- [Godot ScrollContainer Class](https://docs.godotengine.org/en/stable/classes/class_scrollcontainer.html)
- [Godot Window Class](https://docs.godotengine.org/en/stable/classes/class_window.html)
- [Godot Android Export Guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
- [Godot Display Settings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html#class-projectsettings-property-display-window-handheld-orientation)
