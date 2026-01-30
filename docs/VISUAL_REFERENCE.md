# VRMVTube UI - Visual Reference

## What You'll See When Running VRMVTube

This document shows what the application looks like after the HUD overlay implementation.

## Application Window Layout

```
┌────────────────────────────────────────────────────────────────────────┐
│ VRMVTube - Godot Engine                                          ⊡  ▢  ✕ │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  ┌─────────────────────────────────────┬──────────────────────────┐  │
│  │                                     │ VRMVTube             ◀  │  │
│  │                                     ├──────────────────────────┤  │
│  │                                     │ ▲ Scroll Up ▲            │  │
│  │                                     │                          │  │
│  │        BRIGHT GREEN                 │ VTuber Application with  │  │
│  │        BACKGROUND                   │ VRM and MediaPipe        │  │
│  │        (#00FF00)                    │ Support                  │  │
│  │                                     │ Powered by Godot 4.6     │  │
│  │                                     │ ──────────────────────  │  │
│  │        3D Viewport                  │                          │  │
│  │                                     │ Model Management         │  │
│  │        (VRM Model displays here     │ ┌──────────────────────┐ │  │
│  │         when loaded)                │ │ Load VRM Model       │ │  │
│  │                                     │ └──────────────────────┘ │  │
│  │                                     │ ──────────────────────  │  │
│  │        Clean, uncluttered           │                          │  │
│  │        No UI overlays               │ Tracking Controls        │  │
│  │                                     │ ┌──────────────────────┐ │  │
│  │        Chroma key ready for         │ │ Start Tracking       │ │  │
│  │        OBS/streaming                │ └──────────────────────┘ │  │
│  │                                     │                          │  │
│  │                                     │ ┌────────────────────┐   │  │
│  │                                     │ │ Camera Preview     │   │  │
│  │                                     │ │                    │   │  │
│  │                                     │ │    (320x240)       │   │  │
│  │                                     │ │                    │   │  │
│  │                                     │ └────────────────────┘   │  │
│  │                                     │ ──────────────────────  │  │
│  │                                     │                          │  │
│  │                                     │ Settings                 │  │
│  │                                     │ ┌──────────────────────┐ │  │
│  │                                     │ │ Mode: Move           │ │  │
│  │                                     │ └──────────────────────┘ │  │
│  │                                     │                          │  │
│  │                                     │ Camera Controls          │  │
│  │                                     │ Position:                │  │
│  │                                     │ X:█ Y:█ Z:█             │  │
│  │                                     │ Rotation:                │  │
│  │                                     │ X:█ Y:█ Z:█             │  │
│  │                                     │                          │  │
│  │                                     │ Model Transform          │  │
│  │                                     │ Position:                │  │
│  │                                     │ X:█ Y:█ Z:█             │  │
│  │                                     │ Rotation:                │  │
│  │                                     │ X:█ Y:█ Z:█             │  │
│  │                                     │ ──────────────────────  │  │
│  │                                     │                          │  │
│  │                                     │ Status: Ready            │  │
│  │                                     │                          │  │
│  │                                     │ ▼ Scroll Down ▼          │  │
│  └─────────────────────────────────────┴──────────────────────────┘  │
│      Viewport (Expands to fill)            HUD Panel (400px)         │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

## Color Reference

### Green Background (Viewport)

**Color:** #00FF00 (Pure Green)
**RGB:** Red=0, Green=255, Blue=0
**Purpose:** Chroma key for background removal in OBS/streaming

```
██████████  ← This is what you'll see
██        ██    (bright green)
██  GREEN ██
██   BG   ██
██        ██
██████████
```

### HUD Panel

**Background:** Gray panel (Godot default theme)
**Sections:** Separated by horizontal lines
**Buttons:** Standard Godot button style
**Text:** Black on light background

## HUD Sections (Top to Bottom)

### 1. Header
```
┌───────────────────────────┐
│ VRMVTube              ◀  │
└───────────────────────────┘
```
- Title on left
- Collapse button on right (◀ means expanded)

### 2. Product Info
```
VTuber Application with VRM
and MediaPipe Support
Powered by Godot Engine 4.6
```
- Multi-line text
- Auto-wrapping

### 3. Model Management
```
Model Management
┌─────────────────────┐
│ Load VRM Model      │
└─────────────────────┘
```
- Section header
- Button to load .vrm files

### 4. Tracking Controls
```
Tracking Controls
┌─────────────────────┐
│ Start Tracking      │
└─────────────────────┘

┌───────────────────┐
│ Camera Preview    │
│                   │
│   (320x240)       │
│                   │
└───────────────────┘
```
- Section header
- Button to start tracking
- Camera preview area

### 5. Settings
```
Settings
┌─────────────────────┐
│ Mode: Move          │
└─────────────────────┘

Camera Controls
Position:
X:█ Y:█ Z:█
Rotation:
X:█ Y:█ Z:█

Model Transform
Position:
X:█ Y:█ Z:█
Rotation:
X:█ Y:█ Z:█
```
- Mode toggle button
- Camera position spinboxes
- Camera rotation spinboxes
- Model position spinboxes
- Model rotation spinboxes

### 6. Status
```
─────────────────────
Status: Ready
```
- Horizontal separator
- Status message text

## Collapsed State

When you click the ◀ button, the HUD collapses:

```
┌────────────────────────────────────┬─┐
│                                    │V│
│                                    │R│
│                                    │M│
│        BRIGHT GREEN                │V│
│        BACKGROUND                  │T▶│
│        (#00FF00)                   │u│
│                                    │b│
│        3D Viewport                 │e│
│                                    │ │
│        (Much more space)           │ │
│                                    │ │
└────────────────────────────────────┴─┘
```

- HUD shrinks to 50px width
- Vertical "VRMVTube" text
- Expand button ▶
- Viewport gains ~350px more width

## Mouse Interactions

### Viewport Area (Left Side)
- **Left Click + Drag:** Rotate or move camera/model (depends on mode)
- **Scroll Wheel:** Zoom camera/model in/out
- **Right Click:** (Context menu if implemented)

### HUD Panel (Right Side)
- **Scroll Wheel:** Scroll content up/down
- **Click Collapse Button:** Toggle HUD expand/collapse
- **Click Buttons:** Execute actions (Load VRM, Start Tracking)
- **Adjust Spinboxes:** Change camera/model position/rotation

## What to Expect on First Run

1. **Window Opens**
   - Bright green background on left
   - HUD panel on right (expanded)
   - No VRM model yet (needs to be loaded)

2. **Green is Visible**
   - Entire viewport is green
   - Very bright, chroma key green
   - Perfect for streaming

3. **HUD Shows All Controls**
   - Scrollable content
   - All sections visible
   - Ready to use

4. **Status Shows "Ready"**
   - At bottom of HUD
   - Confirms app loaded successfully

## Loading a VRM Model

1. **Click "Load VRM Model" in HUD**
2. **File dialog opens**
3. **Select a .vrm file**
4. **Model appears on green background**

After loading:
```
┌─────────────────────────┬──────┐
│                         │ HUD  │
│     ╔═══╗              │      │
│     ║ ○ ║  ← VRM Model │      │
│     ╠═══╣              │      │
│    ╱     ╲             │      │
│   ╱       ╲            │      │
│  ON GREEN BG            │      │
│                         │      │
└─────────────────────────┴──────┘
```

## Starting Tracking

1. **Click "Start Tracking" in HUD**
2. **Camera preview activates**
3. **Face/hand tracking begins (if MediaPipe available)**
4. **VRM model moves with tracking**

## Using for Streaming

### Setup with OBS

1. **Add Window Capture source**
   - Select VRMVTube window
   
2. **Add Chroma Key filter**
   - Color: Green
   - Similarity: Adjust to remove background
   
3. **Collapse HUD (optional)**
   - Click ◀ to minimize HUD
   - More space for model
   
4. **Position in scene**
   - VRM model now on transparent background
   - Can overlay on game/content

Result:
```
OBS Scene:
┌────────────────────────┐
│  Your Game/Content     │
│                        │
│         ╔═══╗         │ ← VRM model overlay
│         ║ ○ ║         │    (green removed)
│         ╠═══╣         │
│        ╱     ╲        │
│       ╱       ╲       │
│                        │
└────────────────────────┘
```

## Desktop Window Sizes

### 1920x1080 (Full HD)
```
Viewport: 1520px × 1080px (79%)
HUD:      400px × 1080px (21%)
```

### 1280x720 (HD)
```
Viewport: 880px × 720px (69%)
HUD:      400px × 720px (31%)
```

### Collapsed (any resolution)
```
Viewport: Window Width - 50px
HUD:      50px × Window Height
```

## Color Picker Reference

If you need to match the green in OBS:

**Hex:** #00FF00
**RGB:** (0, 255, 0)
**HSV:** (120°, 100%, 100%)
**CMYK:** (100%, 0%, 100%, 0%)

## Keyboard Shortcuts (if implemented in future)

Currently none, but potential shortcuts:
- `Space` - Start/Stop Tracking
- `L` - Load VRM Model
- `C` - Toggle HUD Collapse
- `M` - Toggle Move/Rotate Mode

## Error Messages

You might see these messages (normal in some cases):

**"MediaPipe not available"**
- Tracking won't work
- Camera preview won't update
- Model can still be loaded and viewed

**"Failed to load VRM model"**
- VRM file might be corrupted
- File path might be wrong
- Try a different VRM file

**"Settings file not found, using defaults"**
- First run, no saved settings yet
- Settings will be created on exit

## Summary

The VRMVTube UI now features:

✅ **Clean green viewport** - Perfect for streaming
✅ **Organized HUD panel** - All controls in one place
✅ **Scrollable content** - Access all features
✅ **Collapsible HUD** - Save space when needed
✅ **VRigUnity-style** - Professional VTuber setup

Perfect for VTubing, streaming, and virtual avatar control!
