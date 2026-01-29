# Collapsible Sidebar Implementation

## Overview
All HUD panels are now contained in a single collapsible sidebar, allowing users to maximize viewport space with a single click.

## Features

### Sidebar Header
- **Title**: "HUD Panels"
- **Collapse Button**: ▶ icon
- Positioned at the top of the sidebar

### Expand Tab
- Small button on right edge when sidebar is collapsed
- **Icon**: ◀ (left arrow)
- Always accessible for quick expand

### Panels Included
All these panels collapse together:
1. Title Panel ("VRMVTube")
2. Webcam Preview Panel
3. Buttons Panel (Load Model, Reset Pose, Settings)
4. Model Controls Panel (Position, Scale)
5. Bottom Panel (Platform info, Credits)

## Usage

### Collapsing the Sidebar
1. Click the **▶** button in the sidebar header
2. All panels hide instantly
3. Small expand tab appears on right edge
4. Full viewport available for 3D model

### Expanding the Sidebar
1. Click the **◀** button on the expand tab
2. All panels reappear
3. Full HUD functionality restored

## Visual States

### Expanded (Default)
```
┌────────────────┬─────────────┐
│                │ HUD [▶]     │
│                │─────────────│
│                │ Title       │
│                │─────────────│
│   3D Model     │ Webcam [▼] │
│   Viewport     │ Preview     │
│                │─────────────│
│                │ Buttons     │
│                │─────────────│
│                │ Controls    │
│                │─────────────│
│                │ Info        │
└────────────────┴─────────────┘
```

### Collapsed
```
┌──────────────────────────┬┐
│                          ││
│                          ││
│                          ◀│
│      3D Model Viewport   ││
│      (Full Width)        ││
│                          ││
│                          ││
└──────────────────────────┴┘
```

## Benefits

### For Users
- **More screen space** for 3D model viewing
- **Cleaner interface** when HUD not needed
- **Better for streaming** - Hide UI during broadcasts
- **Better for screenshots** - Capture model without UI clutter
- **Quick toggle** - One click to switch modes

### For VTubers/Streamers
- Hide UI during live streams
- Show model in full glory
- Quick access to controls when needed
- Professional presentation mode

### For Testing/Preview
- Full viewport to check model details
- Hide distractions
- Focus on model appearance
- Easy comparison with/without UI

## Technical Implementation

### Scene Structure
```
UI/Control/
├── SidebarCollapseTab (Button) - Expand button
└── RightPanel (VBoxContainer)
    ├── SidebarHeader (PanelContainer)
    │   └── "HUD Panels" + Collapse Button (▶)
    ├── TitlePanel
    ├── WebcamPreviewPanel
    ├── ButtonsPanel
    ├── ModelControlsPanel
    └── BottomPanel
```

### Script Variables
```gdscript
var sidebar_collapsed := false  # Track sidebar state

@onready var right_panel: VBoxContainer
@onready var sidebar_collapse_button: Button
@onready var sidebar_collapse_tab: Button
```

### Collapse Function
```gdscript
func _on_sidebar_collapse_pressed() -> void:
    sidebar_collapsed = true
    right_panel.visible = false         # Hide all panels
    sidebar_collapse_tab.visible = true # Show expand tab
```

### Expand Function
```gdscript
func _on_sidebar_expand_pressed() -> void:
    sidebar_collapsed = false
    right_panel.visible = true          # Show all panels
    sidebar_collapse_tab.visible = false # Hide expand tab
```

## Behavior

### Default State
- Sidebar **expanded** on app start
- All panels visible
- Expand tab hidden

### After Collapse
- Sidebar **collapsed**
- All panels hidden
- Expand tab visible on right edge

### State Persistence
- Currently resets to expanded on app restart
- Could be saved to settings in future

## Keyboard Shortcuts (Future Enhancement)

Potential additions:
- `Tab` key to toggle sidebar
- `H` key to hide/show HUD
- `F11` for fullscreen mode

## Individual Panel Collapse

The webcam panel still has its own collapse button:
- Independent of sidebar collapse
- Useful when sidebar is expanded
- Collapses just webcam preview content

**Hierarchy:**
1. **Sidebar collapse** - Hides ALL panels
2. **Webcam collapse** - Hides only webcam content (when sidebar expanded)

## Use Cases

### Streaming Setup
1. Configure all settings with sidebar expanded
2. Load and position model
3. Collapse sidebar before going live
4. Full viewport for OBS capture

### Model Inspection
1. Load new VRM model
2. Collapse sidebar for full view
3. Inspect model details
4. Expand sidebar to adjust if needed

### Screenshots
1. Position model as desired
2. Collapse sidebar
3. Take screenshot
4. Expand sidebar for next model

### Presentation Mode
1. Prepare demo with sidebar visible
2. Collapse during presentation
3. Expand for live adjustments
4. Collapse again for clean view

## Compatibility

### Works With
- ✅ All existing features
- ✅ Settings menu
- ✅ Model loading
- ✅ Camera controls
- ✅ Face tracking
- ✅ All button functions

### Doesn't Affect
- 3D viewport rendering
- Model animations
- Camera movement
- Face rigging
- Performance

## Future Enhancements

### Possible Additions
1. **Animation** - Smooth slide in/out
2. **Auto-hide** - Hide after inactivity
3. **Keyboard shortcut** - Quick toggle
4. **Settings persistence** - Remember state
5. **Minimize individual panels** - More granular control
6. **Customizable layout** - User-arranged panels

### Advanced Features
- **Transparency slider** - Semi-transparent panels
- **Docking positions** - Left/right/bottom options
- **Floating panels** - Detachable windows
- **Custom themes** - UI color schemes

## Troubleshooting

### Sidebar Won't Collapse
- Check if `sidebar_collapse_button` is connected
- Verify `right_panel` node reference
- Check console for errors

### Expand Tab Not Visible
- Ensure sidebar is actually collapsed
- Check `sidebar_collapse_tab` visibility property
- Verify button positioning (right edge)

### Panels Missing After Expand
- Check if panels were accidentally deleted
- Verify `right_panel.visible = true` is executed
- Restart app to reset state

## Code Reference

**Files:**
- `scenes/main.tscn` - UI structure
- `scripts/main.gd` - Collapse logic

**Functions:**
- `_on_sidebar_collapse_pressed()` - Hide sidebar
- `_on_sidebar_expand_pressed()` - Show sidebar
- `_ready()` - Connect button signals

**Variables:**
- `sidebar_collapsed` - State tracking
- `right_panel` - Main container
- `sidebar_collapse_button` - Collapse trigger
- `sidebar_collapse_tab` - Expand trigger

---

## Summary

The collapsible sidebar provides users with full control over UI visibility, offering maximum viewport space when needed while keeping all controls easily accessible. Perfect for streaming, screenshots, presentations, and general VTubing workflows.

**Status: FULLY IMPLEMENTED** ✅
