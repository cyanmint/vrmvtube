# Settings HUD Implementation

## Overview

The settings panel has been converted from a popup window to a permanent HUD (Heads-Up Display) panel on the right side of the screen. The panel is scrollable and can be collapsed/expanded.

## Problem Statement

The original design used a popup window for settings that:
- Required a button click to show/hide
- Appeared in the center of the screen, blocking the view
- Was not always visible when needed

## Solution

Implemented a right-side HUD panel that:
- ✅ Always visible (no popup)
- ✅ Scrollable content
- ✅ Foldable/collapsible to save space
- ✅ Positioned on the right side of the screen

## Implementation Details

### Scene Structure

**Before (Popup):**
```
Main
├── VBoxContainer
│   └── ContentContainer
│       ├── ViewportContainer
│       └── CameraPreview
└── SettingsPopup (Window)
    └── ScrollContainer
        └── ControlPanel
```

**After (HUD):**
```
Main
└── VBoxContainer
    └── ContentContainer
        ├── ViewportContainer
        ├── CameraPreview
        └── SettingsHUD (PanelContainer)
            └── VBoxContainer
                ├── Header
                │   ├── TitleLabel ("Settings")
                │   └── CollapseButton ("◀"/"▶")
                └── ScrollContainer
                    └── ControlPanel
```

### Key Components

#### 1. SettingsHUD Panel

**Type:** PanelContainer
**Location:** `VBoxContainer/ContentContainer/SettingsHUD`
**Properties:**
- `custom_minimum_size`: Vector2(350, 0) when expanded
- `custom_minimum_size`: Vector2(50, 0) when collapsed
- `layout_mode`: 2
- `size_flags_vertical`: 3 (expand to fill)

#### 2. Header Section

Contains:
- **TitleLabel**: Displays "Settings"
- **CollapseButton**: Toggle button with arrow icons
  - Expanded state: "◀" (left arrow)
  - Collapsed state: "▶" (right arrow)

#### 3. ScrollContainer

Contains the ControlPanel with all settings controls. Becomes invisible when panel is collapsed.

### Collapse/Expand Functionality

**Script Implementation** (`scripts/main.gd`):

```gdscript
var is_settings_collapsed := false

func _on_collapse_button_pressed():
    is_settings_collapsed = !is_settings_collapsed
    
    if is_settings_collapsed:
        # Collapse: hide scroll container, change button text
        if settings_scroll_container:
            settings_scroll_container.visible = false
        if collapse_button:
            collapse_button.text = "▶"
        if settings_hud:
            settings_hud.custom_minimum_size = Vector2(50, 0)
    else:
        # Expand: show scroll container, change button text
        if settings_scroll_container:
            settings_scroll_container.visible = true
        if collapse_button:
            collapse_button.text = "◀"
        if settings_hud:
            settings_hud.custom_minimum_size = Vector2(350, 0)
```

### Layout Changes

**Internal Panel Layout:**

Changed from horizontal (HBoxContainer) to vertical (VBoxLayoutContainer) stacking:

**Before:**
```
ControlPanel/MarginContainer/HBoxContainer
├── ModeButton
├── CameraPanel
└── ModelPanel
```

**After:**
```
ControlPanel/MarginContainer/VBoxLayoutContainer
├── ModeButton
├── CameraPanel
└── ModelPanel
```

This vertical stacking is better suited for a right-side panel, allowing controls to stack naturally.

## Visual Representation

### Expanded State

```
┌────────────────────────────────────┐
│ VRMVTube                           │
├────────────────────────────────────┤
│ [Load VRM] [Start Tracking]        │
├─────────────────┬──────────────────┤
│                 │ Settings      ◀  │
│                 ├──────────────────┤
│                 │ [Mode: Move]     │
│  3D Viewport    │                  │
│                 │ Camera Controls  │
│  (expands)      │ Position: X Y Z  │
│                 │ Rotation: X Y Z  │
│                 │                  │
│                 │ Model Transform  │
│                 │ Position: X Y Z  │
│                 │ Rotation: X Y Z  │
│                 │                  │
│                 │ (scrollable)     │
└─────────────────┴──────────────────┘
     Wide             350px
```

### Collapsed State

```
┌──────────────────────────────────┐
│ VRMVTube                         │
├──────────────────────────────────┤
│ [Load VRM] [Start Tracking]      │
├────────────────────────────┬─────┤
│                            │ S ▶ │
│                            │ e   │
│  3D Viewport               │ t   │
│                            │ t   │
│  (more space)              │ i   │
│                            │ n   │
│                            │ g   │
│                            │ s   │
│                            │     │
└────────────────────────────┴─────┘
     Much Wider           50px
```

## Code Changes

### Files Modified

1. **scenes/main.tscn**
   - Removed: `SettingsPopup` Window node
   - Removed: Settings button from toolbar
   - Added: `SettingsHUD` PanelContainer
   - Added: Header with title and collapse button
   - Restructured: ControlPanel hierarchy
   - Changed: HBoxContainer to VBoxLayoutContainer for vertical stacking

2. **scripts/main.gd**
   - Removed: `settings_popup` variable
   - Added: `settings_hud`, `collapse_button`, `settings_scroll_container` variables
   - Added: `is_settings_collapsed` state variable
   - Removed: `_on_settings_button_pressed()` function
   - Added: `_on_collapse_button_pressed()` function
   - Updated: `setup_ui_references()` to find new nodes

3. **scripts/control_panel.gd**
   - Updated: All node paths from `MarginContainer/HBoxContainer/` to `MarginContainer/VBoxLayoutContainer/`

## Benefits

### User Experience

1. **Always Accessible**: Settings are always visible, no need to click a button
2. **Space Efficient**: Can collapse to save screen space when not in use
3. **Better Organization**: Vertical layout fits naturally on the right side
4. **Scrollable**: Long lists of settings can be scrolled without overflow
5. **Non-Intrusive**: Doesn't block the 3D viewport or camera preview

### Developer Experience

1. **Simpler Code**: No popup window positioning logic needed
2. **Easier to Test**: Settings always visible during development
3. **Better Integration**: Part of the main scene hierarchy
4. **Responsive**: Automatically adjusts to window height

## Testing

### Compilation Test
```bash
./Godot --headless --check-only --path .
```
✅ Result: No syntax errors

### Runtime Test
```bash
./Godot --headless --path . --quit
```
✅ Result: Application runs without warnings

### Expected Behavior

1. **On Startup**:
   - Settings panel is visible on the right side
   - Panel is in expanded state (350px wide)
   - ScrollContainer is visible with all settings

2. **Click Collapse Button (◀)**:
   - Panel collapses to 50px width
   - ScrollContainer becomes invisible
   - Button changes to "▶"
   - More space for 3D viewport

3. **Click Expand Button (▶)**:
   - Panel expands to 350px width
   - ScrollContainer becomes visible
   - Button changes to "◀"
   - Settings are accessible

4. **Scrolling**:
   - When expanded, scroll wheel works in ScrollContainer
   - All settings remain accessible via scrolling

## Future Enhancements

Possible improvements for the future:

1. **Remember Collapsed State**: Save collapse state in settings file
2. **Resize Handle**: Allow user to drag panel width
3. **Auto-collapse**: Automatically collapse on small screens
4. **Tabs**: Organize settings into tabbed sections
5. **Animations**: Smooth transition when collapsing/expanding
6. **Keyboard Shortcut**: Add hotkey to toggle collapse state

## Migration Notes

### For Users

- **No Settings Button**: The Settings button has been removed from the toolbar
- **Always Visible**: Settings are now always visible on the right side
- **Collapse to Save Space**: Click the arrow button to collapse the panel when not needed

### For Developers

If extending this code:
- Settings panel is at: `VBoxContainer/ContentContainer/SettingsHUD`
- Add new settings to: `SettingsHUD/VBoxContainer/ScrollContainer/ControlPanel`
- Access via: `get_node("VBoxContainer/ContentContainer/SettingsHUD")`

## Related Documentation

- `docs/VIEWPORT_DYNAMIC_RESIZE.md` - Viewport resizing behavior
- `docs/SETTINGS_POPUP_AND_RIGGING.md` - Previous settings implementation
- `scripts/control_panel.gd` - Settings panel logic

## Conclusion

The settings HUD provides a better user experience by:
- Making settings always accessible
- Reducing screen clutter with collapse functionality
- Improving the overall layout with a right-side panel design

All requirements from the problem statement have been successfully implemented:
✅ Settings are now in HUD (not popup)
✅ HUD is on the right side
✅ HUD is scrollable
✅ HUD is foldable/collapsible
