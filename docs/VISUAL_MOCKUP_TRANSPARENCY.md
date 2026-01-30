# VRMVTube HUD Transparency - Visual Mockup

## What You'll See When Running VRMVTube

This document provides a detailed visual representation of how the transparent HUD overlay appears in VRMVTube.

## Full Application Window (1280x720)

### Expanded HUD State

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  ┌────────────────────────────────────────────┬────────────────────────────┐ ║
║  │                                            │╔══════════════════════════╗│ ║
║  │                                            │║ VRMVTube              ◀ ║│ ║
║  │                                            │╟──────────────────────────╢│ ║
║  │             GREEN VIEWPORT                 │║                          ║│ ║
║  │             #00FF00                        │║ VTuber Application with  ║│ ║
║  │             (Chroma Key)                   │║ VRM and MediaPipe...     ║│ ║
║  │                                            │║                          ║│ ║
║  │          [VRM Model Rendered Here]         │╟──────────────────────────╢│ ║
║  │          Camera angle: -10° X              │║ Model Management         ║│ ║
║  │          Position: (0, 1.2, 1)             │║ [Load VRM Model]         ║│ ║
║  │                                            │║                          ║│ ║
║  │       Green background visible through     │╟──────────────────────────╢│ ║
║  │       semi-transparent HUD panel ──────────▶║ Tracking                 ║│ ║
║  │                                            │║ [Start Tracking]         ║│ ║
║  │                                            │║ ┌──────────────────────┐ ║│ ║
║  │                                            │║ │  Camera Preview      │ ║│ ║
║  │                                            │║ │  [Webcam feed here]  │ ║│ ║
║  │                                            │║ └──────────────────────┘ ║│ ║
║  │                                            │║                          ║│ ║
║  │                                            │╟──────────────────────────╢│ ║
║  │                                            │║ Settings                 ║│ ║
║  │                                            │║ Camera Position          ║│ ║
║  │                                            │║ X: [0.00]  Y: [1.20]     ║│ ║
║  │                                            │║ Z: [1.00]                ║│ ║
║  │                                            │║ Camera Rotation          ║│ ║
║  │                                            │║ X: [-10.0] Y: [0.0]      ║│ ║
║  │                                            │║ Z: [0.0]                 ║│ ║
║  │                                            │║ Model Transform          ║│ ║
║  │                                            │║ Position: (0,0,0)        ║│ ║
║  │                                            │║ Rotation: (0,0,0)        ║│ ║
║  │                                            │║                          ║│ ║
║  │                                            │╟──────────────────────────╢│ ║
║  │                                            │║ Status: Ready            ║│ ║
║  └────────────────────────────────────────────┴╚══════════════════════════╝┘ ║
║         70% Viewport Width                         30% HUD Width             ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### Collapsed HUD State

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  ┌──────────────────────────────────────────────────────────────────┬─────┐ ║
║  │                                                                  │╔═══╗│ ║
║  │                                                                  │║ V ║│ ║
║  │                                                                  │║ R ║│ ║
║  │                                                                  │║ M ║│ ║
║  │             GREEN VIEWPORT                                       │║ V ║│ ║
║  │             #00FF00                                              │║ T ▶║│ ║
║  │             (Chroma Key)                                         │║ u ║│ ║
║  │                                                                  │║ b ║│ ║
║  │          [VRM Model Rendered Here]                               │║ e ║│ ║
║  │          Camera angle: -10° X                                    │║   ║│ ║
║  │          Position: (0, 1.2, 1)                                   │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │       Maximum viewport space for model                           │║   ║│ ║
║  │       HUD collapsed to save space                                │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  │                                                                  │║   ║│ ║
║  └──────────────────────────────────────────────────────────────────┴╚═══╝┘ ║
║         95% Viewport Width                            5% HUD Width           ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## HUD Transparency Details

### Color Visualization

```
┌─────────────────────────────────────┐
│ HUD Background Color                │
│                                     │
│ ████████████████████████████████    │ <- What you see
│ RGB: (0.1, 0.1, 0.1) = #1A1A1A      │
│ Alpha: 0.7 (70% opacity)            │
│                                     │
│ Underlying Green: #00FF00           │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░    │ <- Green shows through
│                                     │
│ Final appearance:                   │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    │ <- Dark with green tint
└─────────────────────────────────────┘
```

### Border Visualization

```
╔═══════════════════════════════════════╗
║ 2px border, 80% opacity               ║
║ ┌───────────────────────────────────┐ ║
║ │ 5px rounded corners               │ ║
║ │                                   │ ║
║ │   Panel content area              │ ║
║ │   70% opacity background          │ ║
║ │                                   │ ║
║ └───────────────────────────────────┘ ║
╚═══════════════════════════════════════╝
```

## Camera Angle Visualization

### Side View (Showing -10° X Rotation)

```
        Camera at (0, 1.2, 1)
                ↓
               📷
              / ↑ -10°
             /  │
            /   │
           /    │
     ─────/─────▼─────── Y = 0 plane
         /      ↓
        /   VRM Model
       /    at origin
      /     (0, 0, 0)
     /         │
   Z=1        👤
```

### Angle Breakdown

```
Top View (Looking Down):
        Z
        ↑
        │
        │  Camera
        │    ●
        │    │
        │    │
        │    │
  ──────┼────┼────▶ X
        │    │
        │    │
      👤Model
```

```
Side View (X=0 plane):
        Y
        ↑
        │
      1.2    ●──── Camera (tilted -10°)
        │   /
        │  / viewing ray
        │ ↙
      0 ┼ 👤 Model
        │
  ──────┴──────▶ Z
        0     1
```

## Transparency Effect Examples

### Example 1: Text on Transparent Background

```
┌────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │ <- Dark transparent BG
│ ▓▓ VRMVTube              ◀ ▓▓ │
│ ▓▓──────────────────────────▓▓ │
│ ▓▓                          ▓▓ │
│ ▓▓ White text on dark BG    ▓▓ │ <- Text readable
│ ▓▓ with 70% transparency    ▓▓ │
│ ▓▓                          ▓▓ │
│ ▓▓ Green #00FF00 shows      ▓▓ │
│ ▓▓ through the panel        ▓▓ │ <- Green tint visible
│ ▓▓                          ▓▓ │
└────────────────────────────────┘
```

### Example 2: Buttons on Transparent Background

```
┌────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓▓ ┌──────────────────────┐ ▓▓ │
│ ▓▓ │  Load VRM Model      │ ▓▓ │ <- Button with BG
│ ▓▓ └──────────────────────┘ ▓▓ │
│ ▓▓                          ▓▓ │
│ ▓▓ ┌──────────────────────┐ ▓▓ │
│ ▓▓ │  Start Tracking      │ ▓▓ │ <- Buttons stand out
│ ▓▓ └──────────────────────┘ ▓▓ │
│ ▓▓                          ▓▓ │
└────────────────────────────────┘
```

## Aspect Ratio Behavior

### Portrait Mode (Mobile/Tablet)

```
┌──────────────┐
│              │
│   ┌────┬───┐ │
│   │    │╔═╗│ │
│   │    │║ ║│ │
│   │    │║V║│ │
│   │ G  │║R║│ │ <- HUD on right
│   │ R  │║M▶║│
│   │ E  │║V║│ │
│   │ E  │║T║│ │
│   │ N  │║u║│ │
│   │    │║b║│ │
│   │ V  │║e║│ │
│   │ P  │║ ║│ │
│   │    │╚═╝│ │
│   └────┴───┘ │
│              │
│   Viewport   │
│   stretches  │
│   to fill    │
│   portrait   │
│   screen     │
│              │
└──────────────┘
```

### Landscape Mode (Desktop/TV)

```
┌────────────────────────────────────────┐
│ ┌──────────────────────────┬─────────┐ │
│ │                          │╔═══════╗│ │
│ │                          │║ HUD   ║│ │
│ │   GREEN VIEWPORT         │║       ║│ │
│ │   Wide screen            │║       ║│ │
│ │   [VRM Model]            │║       ║│ │
│ │                          │╚═══════╝│ │
│ └──────────────────────────┴─────────┘ │
└────────────────────────────────────────┘
```

### Window Resize Animation

```
Step 1: Small Window (800x600)
┌────────────────┐
│ ┌──────┬─────┐ │
│ │      │╔═══╗│ │
│ │Green │║HUD║│ │
│ │      │╚═══╝│ │
│ └──────┴─────┘ │
└────────────────┘

Step 2: Resizing (1024x768)
┌──────────────────────┐
│ ┌──────────┬───────┐ │
│ │          │╔═════╗│ │
│ │  Green   │║ HUD ║│ │
│ │ Expands  │║     ║│ │
│ │          │╚═════╝│ │
│ └──────────┴───────┘ │
└──────────────────────┘

Step 3: Large Window (1920x1080)
┌────────────────────────────────────┐
│ ┌────────────────────┬───────────┐ │
│ │                    │╔═════════╗│ │
│ │                    │║  HUD    ║│ │
│ │   Green Viewport   │║         ║│ │
│ │   Maximized        │║         ║│ │
│ │                    │║         ║│ │
│ │                    │╚═════════╝│ │
│ └────────────────────┴───────────┘ │
└────────────────────────────────────┘
```

## Color Swatches

### HUD Background

```
┌───────────────────────┐
│ Name: Dark Gray       │
│ RGB: (0.1, 0.1, 0.1)  │
│ Hex: #1A1A1A          │
│ Opacity: 70%          │
│                       │
│ █████████████████     │ <- Appearance
└───────────────────────┘
```

### HUD Border

```
┌───────────────────────┐
│ Name: Medium Gray     │
│ RGB: (0.3, 0.3, 0.3)  │
│ Hex: #4D4D4D          │
│ Opacity: 80%          │
│                       │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓     │ <- Appearance
└───────────────────────┘
```

### Viewport Background

```
┌───────────────────────┐
│ Name: Chroma Key Green│
│ RGB: (0.0, 1.0, 0.0)  │
│ Hex: #00FF00          │
│ Opacity: 100%         │
│                       │
│ ░░░░░░░░░░░░░░░░░     │ <- Pure green
└───────────────────────┘
```

## Interaction Examples

### Mouse Over Button

```
Before:
┌────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓▓ [Load VRM Model]     ▓▓ │ <- Normal state
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
└────────────────────────────┘

After (Hover):
┌────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓▓ ┏━━━━━━━━━━━━━━━━━┓  ▓▓ │ <- Highlighted
│ ▓▓ ┃Load VRM Model   ┃  ▓▓ │
│ ▓▓ ┗━━━━━━━━━━━━━━━━━┛  ▓▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
└────────────────────────────┘
```

### Scrolling Content

```
Top of scroll:
┌────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓▓ Product Info         ▓▓ │
│ ▓▓ Model Management     ▓▓ │
│ ▓▓ Tracking             ▓▓ │
│ ▓▓ Settings...      [▲] ▓▓ │ <- Scroll indicator
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
└────────────────────────────┘

Scrolled down:
┌────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓▓ Settings...      [▼] ▓▓ │ <- Different content
│ ▓▓ Camera Position      ▓▓ │
│ ▓▓ Model Transform      ▓▓ │
│ ▓▓ Status               ▓▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
└────────────────────────────┘
```

## Summary

This visual mockup demonstrates:

✅ **HUD Transparency:**
- Semi-transparent dark panel (70% opacity)
- Green viewport visible through HUD
- Rounded corners with subtle border
- Modern, professional appearance

✅ **Camera Angle:**
- -10° X rotation for better framing
- Slightly downward viewing angle
- Natural perspective for VRM characters

✅ **Responsive Layout:**
- Adapts to any window size
- Works in portrait and landscape
- No aspect ratio constraint
- Maximum screen usage

All visual elements implemented and ready for use! 🎨
