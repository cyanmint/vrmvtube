# HUD Input Visual Guide

## Overview

Visual diagrams showing how mouse input is handled in different areas of the application.

## Layout with Input Zones

### Full Window Layout

```
┌────────────────────────────────────────────────────────────────┐
│                                            [Show HUD ▶]        │ Zone 3
├────────────────────────────────────┬───────────────────────────┤
│                                    │╔═════════════════════════╗│
│                                    │║ VRMVTube              ◀ ║│ Zone 2
│                                    │╟─────────────────────────╢│ HUD
│                                    │║ Product Info            ║│ Overlay
│         Zone 1                     │║                         ║│
│      Green Viewport                │║ [Load VRM]              ║│
│     (Camera Control)               │║                         ║│
│                                    │║ [Start Tracking]        ║│
│  Click & Drag here to move         │║                         ║│
│  camera or rotate camera           │║ Camera Preview          ║│
│                                    │║                         ║│
│  Scroll wheel to zoom in/out       │║ Settings...             ║│
│                                    │║  - Camera Position      ║│
│                                    │║  - Camera Rotation      ║│
│  [VRM Model Display]               │║  - Model Position       ║│
│                                    │║  - Model Rotation       ║│
│                                    │║                         ║│
│                                    │║ Status: Ready           ║│
│                                    │╚═════════════════════════╝│
└────────────────────────────────────┴───────────────────────────┘
```

### Input Zones Explained

#### Zone 1: Viewport (Camera Control Area)
- **Location:** Left side, full height
- **Width:** Window width minus HUD width (dynamic)
- **Background:** Green (#00FF00)
- **Input Behavior:**
  - ✅ Mouse drag controls camera/model
  - ✅ Scroll wheel controls zoom/rotation
  - ✅ Input events processed by `_input()`

#### Zone 2: HUD Overlay (UI Control Area)
- **Location:** Right side, full height
- **Width:** Fixed 400px
- **Background:** Semi-transparent dark gray
- **Input Behavior:**
  - ✅ Buttons, spinboxes, scrollbars work
  - ❌ Mouse drag does NOT control camera/model
  - ❌ Input events filtered out from camera control

#### Zone 3: Show HUD Button (When HUD Hidden)
- **Location:** Top-right corner
- **Size:** 110px × 40px
- **Input Behavior:**
  - ✅ Button click reopens HUD
  - ❌ Mouse click does NOT control camera/model

## Before Fix: Input Bleeding Issue

### Problem Diagram

```
┌────────────────────────────────────┬───────────────────────────┐
│                                    │╔═════════════════════════╗│
│         Viewport                   │║      HUD Panel          ║│
│      (Camera moves)                │║  (Controls work)        ║│
│                                    │╟─────────────────────────╢│
│  User drags here ───────────────→  │║  [Button] ←── Click     ║│
│  expecting to move camera          │║                         ║│
│                                    │║  Camera ALSO moves! ❌  ║│
│  Camera moves ✓                    │║  Button clicks ✓        ║│
│  BUT...                            │║                         ║│
│  Camera ALSO moves when            │║  User confused by       ║│
│  dragging on HUD! ❌               │║  dual behavior ❌       ║│
│                                    │╚═════════════════════════╝│
└────────────────────────────────────┴───────────────────────────┘

Issue: Input events in HUD area triggered BOTH:
- HUD control interactions (expected)
- Camera/model movement (unexpected)
```

## After Fix: Clean Input Separation

### Solution Diagram

```
┌────────────────────────────────────┬───────────────────────────┐
│                                    │╔═════════════════════════╗│
│         Viewport                   │║      HUD Panel          ║│
│      (Camera moves)                │║  (Controls only)        ║│
│                                    │╟─────────────────────────╢│
│  User drags here ───────────────→  │║  [Button] ←── Click     ║│
│  Camera moves ✓                    │║                         ║│
│                                    │║  Camera does NOT        ║│
│  Input handled by                  │║  move when clicking     ║│
│  _input() function                 │║  here! ✓                ║│
│                                    │║                         ║│
│  ╔════════════════════════════╗    │║  Input filtered out     ║│
│  ║ HUD area check prevents   ║    │║  from camera control ✓  ║│
│  ║ camera control if mouse   ║    │║                         ║│
│  ║ is over HUD overlay       ║    │║  Only HUD controls      ║│
│  ╚════════════════════════════╝    │║  receive events ✓       ║│
│                                    │╚═════════════════════════╝│
└────────────────────────────────────┴───────────────────────────┘

Solution: Input filtering checks if mouse is over HUD:
- If over HUD → skip camera/model control
- If over viewport → handle camera/model control
```

## Mouse Event Flow

### Event Processing Sequence

```
┌─────────────────────────────────────────────────────────────────┐
│                      Mouse Event                                │
│              (Click, Drag, Scroll, etc.)                        │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
         ┌───────────────────────────────┐
         │  Godot GUI Input System       │
         │  (Buttons, Scrollbars, etc.)  │
         └──────────┬────────────────────┘
                    │ If not consumed
                    ▼
         ┌───────────────────────────────┐
         │  _input() function called     │
         └──────────┬────────────────────┘
                    │
                    ▼
         ┌───────────────────────────────┐
         │  Check: Mouse over viewport?  │
         └──────────┬────────────────────┘
                    │ No → Return
                    │ Yes
                    ▼
         ┌───────────────────────────────┐
         │  NEW: Check if over HUD?      │
         └──────────┬────────────────────┘
                    │ Yes → Return (filtered)
                    │ No
                    ▼
         ┌───────────────────────────────┐
         │  NEW: Check if over button?   │
         └──────────┬────────────────────┘
                    │ Yes → Return (filtered)
                    │ No
                    ▼
         ┌───────────────────────────────┐
         │  Handle camera/model input    │
         │  - Drag to move/rotate        │
         │  - Scroll to zoom             │
         └───────────────────────────────┘
```

### Code Flow Visualization

```gdscript
func _input(event: InputEvent) -> void:
    ┌─────────────────────────────────┐
    │ if not viewport_container:     │
    │     return                      │
    └────────────┬────────────────────┘
                 │
                 ▼
    ┌─────────────────────────────────┐
    │ is_over_viewport?               │
    │ (Check viewport bounds)         │
    └────────────┬────────────────────┘
                 │ No → return
                 │ Yes
                 ▼
    ┌─────────────────────────────────┐
    │ NEW: Is mouse over HUD?         │
    │ hud_rect.has_point(mouse_pos)?  │
    └────────────┬────────────────────┘
                 │ Yes → return ← Filter out!
                 │ No
                 ▼
    ┌─────────────────────────────────┐
    │ NEW: Is mouse over button?      │
    │ button_rect.has_point()?        │
    └────────────┬────────────────────┘
                 │ Yes → return ← Filter out!
                 │ No
                 ▼
    ┌─────────────────────────────────┐
    │ Process camera/model input      │
    │ - Handle drag                   │
    │ - Handle scroll                 │
    └─────────────────────────────────┘
```

## Interaction Examples

### Example 1: Dragging on Viewport

```
User Action: Click and drag on green viewport
┌────────────────────────────────────┬───────────────────────────┐
│    🖱️ Mouse Click & Drag           │╔═════════════════════════╗│
│    ↓   ↓   ↓                       │║      HUD Panel          ║│
│    •━━━━━→ •                       │║                         ║│
│                                    │║                         ║│
│  Camera Position Changes:          │║  No HUD interaction     ║│
│  X: 0.0 → -0.5                     │║                         ║│
│  Y: 1.2 → 1.4                      │║                         ║│
│                                    │╚═════════════════════════╝│
└────────────────────────────────────┴───────────────────────────┘

Result: ✅ Camera moves
        ✅ HUD unaffected
```

### Example 2: Clicking Button on HUD

```
User Action: Click [Load VRM] button on HUD
┌────────────────────────────────────┬───────────────────────────┐
│                                    │╔═════════════════════════╗│
│         Viewport                   │║      HUD Panel          ║│
│                                    │║                         ║│
│                                    │║  [Load VRM] ←── 🖱️ Click│
│                                    │║         ↓               ║│
│  Camera Position:                  │║   File dialog opens     ║│
│  X: 0.0 (unchanged)                │║                         ║│
│  Y: 1.2 (unchanged)                │║                         ║│
│                                    │╚═════════════════════════╝│
└────────────────────────────────────┴───────────────────────────┘

Result: ✅ Button clicked
        ✅ File dialog opens
        ✅ Camera does NOT move
```

### Example 3: Scrolling on HUD

```
User Action: Scroll wheel over HUD settings
┌────────────────────────────────────┬───────────────────────────┐
│                                    │╔═════════════════════════╗│
│         Viewport                   │║      HUD Panel          ║│
│                                    │║                         ║│
│                                    │║  Settings Section       ║│
│                                    │║  ┌─────────────────┐    ║│
│  Camera Position:                  │║  │ Camera X: 0.0   │    ║│
│  Z: 1.0 (unchanged)                │║  │ Camera Y: 1.2   │🖱️  ║│
│                                    │║  │ Camera Z: 1.0   │↕️  ║│
│  No zoom change                    │║  │ Model X: 0.0    │    ║│
│                                    │║  └─────────────────┘    ║│
│                                    │║      ↕️ ScrollContainer  ║│
│                                    │╚═════════════════════════╝│
└────────────────────────────────────┴───────────────────────────┘

Result: ✅ HUD scrolls
        ✅ Camera does NOT zoom
```

### Example 4: Dragging Across Boundary

```
User Action: Start drag on viewport, move to HUD
┌────────────────────────────────────┬───────────────────────────┐
│    🖱️ Start here                   │╔═════════════════════════╗│
│    •━━━━━→ Move across ━━━━━━━━━→ │║ • End here              ║│
│    ↓                               │║  ↓                      ║│
│  Camera starts moving              │║  Camera stops moving    ║│
│                                    │║  when mouse enters HUD  ║│
│                                    │╚═════════════════════════╝│
└────────────────────────────────────┴───────────────────────────┘

Result: ✅ Camera moves while in viewport
        ✅ Camera stops when entering HUD
        ✅ Clean transition
```

## Fixed Width Visualization

### Window Resize Behavior

#### Narrow Window (800px wide)
```
┌────────────────┬─────────────────┐
│                │╔═══════════════╗│
│   Viewport     │║ HUD 400px     ║│ ← Fixed width
│   400px wide   │║               ║│
│                │╚═══════════════╝│
└────────────────┴─────────────────┘
     50%              50%
```

#### Medium Window (1280px wide)
```
┌──────────────────────────┬─────────────────┐
│                          │╔═══════════════╗│
│       Viewport           │║ HUD 400px     ║│ ← Fixed width
│       880px wide         │║               ║│
│                          │╚═══════════════╝│
└──────────────────────────┴─────────────────┘
        ~69%                    ~31%
```

#### Wide Window (1920px wide)
```
┌────────────────────────────────────┬─────────────────┐
│                                    │╔═══════════════╗│
│           Viewport                 │║ HUD 400px     ║│ ← Fixed width
│           1520px wide              │║               ║│
│                                    │╚═══════════════╝│
└────────────────────────────────────┴─────────────────┘
              ~79%                         ~21%
```

**Key Points:**
- HUD width always 400px (fixed)
- Viewport width adjusts (fills remaining space)
- No aspect ratio constraint
- Responsive to window width changes

### Height Resize Behavior

#### Short Window (600px tall)
```
┌────────────────────────┬─────────────────┐
│                        │╔═══════════════╗│
│      Viewport          │║ HUD           ║│
│      600px tall        │║ 600px tall    ║│ ← Grows with window
│                        │╚═══════════════╝│
└────────────────────────┴─────────────────┘
```

#### Tall Window (1080px tall)
```
┌────────────────────────┬─────────────────┐
│                        │╔═══════════════╗│
│                        │║               ║│
│      Viewport          │║     HUD       ║│
│      1080px tall       │║ 1080px tall   ║│ ← Grows with window
│                        │║               ║│
│                        │╚═══════════════╝│
└────────────────────────┴─────────────────┘
```

**Key Points:**
- HUD height matches window height
- Viewport height matches window height
- Both fill vertical space
- ScrollContainer handles overflow in HUD

## Testing Checklist

### Visual Tests

- [ ] HUD width is 400px regardless of window width
- [ ] HUD height matches window height
- [ ] HUD overlays on top of viewport
- [ ] Green viewport visible behind transparent HUD
- [ ] Show HUD button visible when HUD hidden

### Input Tests

- [ ] Dragging on viewport moves camera
- [ ] Dragging on HUD does NOT move camera
- [ ] Clicking HUD buttons works correctly
- [ ] Clicking Show HUD button works correctly
- [ ] Scrolling on viewport zooms camera
- [ ] Scrolling on HUD scrolls settings (if overflow)
- [ ] Dragging from viewport to HUD stops camera movement

### Responsiveness Tests

- [ ] Resize window wider → HUD stays 400px
- [ ] Resize window narrower → HUD stays 400px
- [ ] Resize window taller → HUD grows vertically
- [ ] Resize window shorter → HUD shrinks vertically
- [ ] Portrait orientation → HUD fills height
- [ ] Landscape orientation → HUD fills height

## Conclusion

The fix provides:
- ✅ Fixed HUD width (400px, no aspect ratio)
- ✅ Clean input separation
- ✅ Professional user experience
- ✅ Intuitive interaction patterns

All requirements successfully implemented!
