# HUD Input Fix Documentation

## Overview

This document describes the fix for preventing mouse input on the HUD overlay from also controlling the camera/model underneath.

## Problem Statement

1. **Overlay aspect ratio issue:** The overlay should not maintain aspect ratio - the width should be fixed
2. **Input bleeding issue:** Dragging on the overlay should not also drag the model or camera

## Solutions Implemented

### 1. Fixed Width Overlay (Already Correct)

The HUD overlay width was already properly configured to remain fixed at 400px.

**Scene Configuration (scenes/main.tscn):**
```gdscript
[node name="HUDOverlay" type="PanelContainer" parent="."]
custom_minimum_size = Vector2(400, 0)    # Width fixed at 400px
layout_mode = 1
anchors_preset = 6
anchor_left = 1.0                         # Anchored to right edge
anchor_top = 0.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -400.0                      # Positioned 400px from right
grow_horizontal = 0                       # No horizontal growth
grow_vertical = 2                         # Vertical growth with window
```

**Result:**
- Width always 400px (no aspect ratio maintenance)
- Height adjusts with window size
- Anchored to right edge
- Clean overlay appearance

### 2. Input Event Filtering (New Fix)

Added mouse input filtering to prevent camera/model control when clicking on HUD.

**Code Changes (scripts/main.gd):**

```gdscript
func _input(event: InputEvent) -> void:
    if not viewport_container:
        return
    
    # Check if mouse is over viewport
    var viewport_rect := viewport_container.get_global_rect()
    var mouse_pos := get_viewport().get_mouse_position()
    var is_over_viewport := viewport_rect.has_point(mouse_pos)
    
    if not is_over_viewport:
        return
    
    # NEW: Check if mouse is over HUD overlay
    if settings_hud and settings_hud.visible:
        var hud_rect := settings_hud.get_global_rect()
        if hud_rect.has_point(mouse_pos):
            # Mouse is over HUD - let HUD controls handle input
            return
    
    # NEW: Check if mouse is over show HUD button
    if show_hud_button and show_hud_button.visible:
        var button_rect := show_hud_button.get_global_rect()
        if button_rect.has_point(mouse_pos):
            # Mouse is over button - let button handle input
            return
    
    # Only handle camera/model input if mouse is over viewport
    # AND not over HUD/button
    # ... rest of input handling code
```

## Input Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     Mouse Input Event                   │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ Over viewport?       │
            └──────┬───────────────┘
                   │ No → Return (ignore)
                   │ Yes
                   ▼
            ┌──────────────────────┐
            │ Over HUD overlay?    │
            └──────┬───────────────┘
                   │ Yes → Return (HUD handles)
                   │ No
                   ▼
            ┌──────────────────────┐
            │ Over HUD button?     │
            └──────┬───────────────┘
                   │ Yes → Return (button handles)
                   │ No
                   ▼
            ┌──────────────────────┐
            │ Handle camera/model  │
            │ input (drag/scroll)  │
            └──────────────────────┘
```

## Behavior Comparison

### Before Fix

| Action | HUD Visible | Result |
|--------|-------------|--------|
| Drag on viewport | Yes | Camera moves + HUD might receive events |
| Drag on HUD | Yes | Camera moves + HUD controls work |
| Click HUD button | Yes | Camera starts dragging + Button clicks |

**Issues:**
- Confusing dual input
- Accidental camera movement
- Poor user experience

### After Fix

| Action | HUD Visible | Result |
|--------|-------------|--------|
| Drag on viewport | Yes | Camera moves only |
| Drag on HUD | Yes | HUD controls work only |
| Click HUD button | Yes | Button clicks only |

**Improvements:**
- Clean input separation
- No accidental camera movement
- Intuitive behavior
- Professional UX

## Testing Scenarios

### Test 1: Viewport Dragging
**Steps:**
1. Open application
2. Position mouse over green viewport (not over HUD)
3. Click and drag

**Expected:**
- ✅ Camera/model moves
- ✅ No HUD interference

### Test 2: HUD Dragging
**Steps:**
1. Open application
2. HUD should be visible on right side
3. Position mouse over HUD
4. Click and drag

**Expected:**
- ✅ Camera/model does NOT move
- ✅ HUD scrolling works (if content overflows)
- ✅ Can interact with HUD controls

### Test 3: HUD Button Clicking
**Steps:**
1. Open application
2. Click "◀" collapse button on HUD

**Expected:**
- ✅ Camera/model does NOT move
- ✅ HUD hides
- ✅ "Show HUD ▶" button appears

### Test 4: Show HUD Button
**Steps:**
1. HUD is hidden
2. Click "Show HUD ▶" button in top-right

**Expected:**
- ✅ Camera/model does NOT move
- ✅ HUD reappears
- ✅ Button hides

### Test 5: Mixed Interaction
**Steps:**
1. Drag on viewport (move camera)
2. Move mouse to HUD without releasing
3. Continue dragging

**Expected:**
- ✅ Camera stops moving when mouse enters HUD
- ✅ HUD scrolling may occur
- ✅ Clean transition between areas

## Technical Details

### Mouse Position Detection

**Global Rect Method:**
```gdscript
# Get the screen-space rectangle of a control
var rect := control.get_global_rect()

# Check if mouse is within rectangle
var mouse_pos := get_viewport().get_mouse_position()
var is_over := rect.has_point(mouse_pos)
```

**Benefits:**
- Works with overlapping controls
- Accurate screen-space coordinates
- Handles control transformations
- Simple and performant

### Control Layering

The HUD overlay is rendered on top of the viewport because:
1. It's added as a later child in the scene tree
2. Both are children of the same parent (Main)
3. Godot renders children in order

**Scene Hierarchy:**
```
Main (Control)
├── ViewportContainer (full screen)
│   └── SubViewport
│       └── 3D content
├── ShowHUDButton (top-right)
└── HUDOverlay (right side, overlays viewport)
```

### Event Propagation

When an event is received:
1. Godot checks GUI input first (buttons, scrollbars, etc.)
2. Then calls `_input()` on scripts
3. Our check prevents camera/model input if over HUD
4. HUD controls still receive their GUI events normally

## Fixed Width Explanation

### Why Width is Fixed

**Design Goal:**
- HUD should have consistent width for readability
- Content should be predictable
- No horizontal squishing/stretching

**Implementation:**
```gdscript
custom_minimum_size = Vector2(400, 0)
# - X (400): Minimum width is 400px
# - Y (0): No minimum height constraint

grow_horizontal = 0
# - Don't grow horizontally with window resize

grow_vertical = 2
# - Grow vertically to fill parent height
```

### Width vs. Height Behavior

| Window Action | HUD Width | HUD Height |
|---------------|-----------|------------|
| Resize wider | 400px (fixed) | Unchanged |
| Resize narrower | 400px (fixed) | Unchanged |
| Resize taller | 400px (fixed) | Increases |
| Resize shorter | 400px (fixed) | Decreases |
| Portrait → Landscape | 400px (fixed) | Decreases |
| Landscape → Portrait | 400px (fixed) | Increases |

**Conclusion:**
- Width always 400px (no aspect ratio)
- Height adjusts to window (fills vertical space)
- Perfect for overlay design

## Benefits

### User Experience
- ✅ No accidental camera movement when using HUD
- ✅ Clear visual and functional separation
- ✅ Intuitive input behavior
- ✅ Professional application feel

### Code Quality
- ✅ Clean input handling logic
- ✅ Proper event routing
- ✅ Maintainable code structure
- ✅ Well-documented behavior

### Streaming/VTubing
- ✅ Fixed HUD width for consistent layout
- ✅ No interference with camera control
- ✅ Easy to use while streaming
- ✅ Professional appearance

## Future Enhancements

### Possible Improvements
1. **Configurable HUD width** - Allow users to adjust HUD width
2. **HUD transparency control** - Slider to adjust opacity
3. **HUD themes** - Different color schemes
4. **Drag HUD to reposition** - Move HUD to left/right/floating
5. **Multiple HUD panels** - Separate panels for different functions

### Input Handling Extensions
1. **Touch support** - Handle touch events properly
2. **Multi-touch** - Support pinch to zoom on touch devices
3. **Gamepad support** - Camera control via gamepad
4. **Keyboard shortcuts** - Alternative input methods

## Conclusion

Both requirements successfully implemented:
1. ✅ HUD width is fixed at 400px (no aspect ratio maintenance)
2. ✅ Dragging on HUD does not control camera/model

The fix provides clean input separation and professional user experience.
