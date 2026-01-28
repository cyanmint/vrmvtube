# Portrait Mode Implementation

## Overview

VRMVTube now runs in **portrait orientation by default** (720x1280), optimized for mobile VTubing and vertical video content.

## Changes

### 1. Portrait Orientation

**Display Settings:**
- Width: 720 pixels
- Height: 1280 pixels
- Aspect Ratio: 9:16 (vertical)

**Why Portrait?**
- Perfect for mobile devices (phones, tablets)
- Matches social media platforms (TikTok, Instagram, YouTube Shorts)
- Better for vertical streaming
- More natural for VTubing on mobile

### 2. Character Positioning

**Default Position:**
- Y: -0.3 (centered for portrait view)
- Scale: 1.5x (fills vertical frame nicely)

**Character Framing:**
- Face in upper-middle portion
- Upper body visible
- Good composition for portrait format
- Centered in viewport

### 3. Bottom Toggle Button

**Location:** Bottom of screen, always visible

**Functionality:**
- Toggles sidebar visibility
- Easy thumb access on mobile
- Works with both touch and mouse
- Uses universal menu icon (☰)

**Button Appearance:**
```
┌────────────────┐
│                │
│  Toggle HUD ☰  │
└────────────────┘
```

### 4. Portrait Layout

**HUD Hidden (Default):**
```
┌──────────────────┐
│                  │
│                  │
│   VRM Character  │
│    (Centered)    │
│                  │
│                  │
│                  │
│                  │
│                  │
│                  │
├──────────────────┤
│  [Toggle HUD ☰]  │
└──────────────────┘
```

**HUD Visible:**
```
┌──────┬───────────┐
│      │  VRMVTube │
│      │  Webcam   │
│ 3D   │  Preview  │
│View  ├───────────┤
│      │  Buttons  │
│      ├───────────┤
│      │ Controls  │
│      ├───────────┤
│      │ Settings  │
├──────┼───────────┤
│  [Toggle HUD ☰]  │
└──────┴───────────┘
```

## Use Cases

### Mobile VTubing
- Hold phone vertically
- Character fills screen perfectly
- Tap bottom button for controls
- Ideal for mobile streaming

### Vertical Video Content
- TikTok-style videos
- Instagram Stories/Reels
- YouTube Shorts
- Vertical live streams

### Professional Streaming
- Clean, focused composition
- Character prominently featured
- Easy access to controls
- Professional appearance

## Platform Support

### Mobile Devices
- ✅ Android phones/tablets
- ✅ iOS devices (when supported)
- ✅ Touch-optimized controls
- ✅ One-handed operation

### Desktop
- ✅ Works in portrait window
- ✅ Can resize as needed
- ✅ Mouse-friendly controls
- ✅ Keyboard shortcuts still work

### Web
- ✅ Embedded portrait players
- ✅ Mobile web browsers
- ✅ Responsive design
- ✅ Touch and mouse support

## Benefits

### For Content Creators
- **Mobile-first design** - Create content anywhere
- **Vertical format** - Matches modern platforms
- **Easy controls** - Toggle HUD with one tap
- **Professional quality** - Clean, focused layout

### For Viewers
- **Full-screen character** - No wasted space
- **Clean presentation** - HUD hidden by default
- **Mobile-friendly** - Perfect viewing on phones
- **Engaging format** - Vertical video is popular

### For Developers
- **Modern design** - Follows current trends
- **Responsive layout** - Adapts to different screens
- **Touch-optimized** - Great mobile UX
- **Flexible** - Can still use landscape if needed

## Technical Details

### Project Configuration
```ini
[display]
window/size/viewport_width=720
window/size/viewport_height=1280
window/stretch/mode="canvas_items"
```

### Default Model Settings
```gdscript
DEFAULT_MODEL_POSITION = Vector3(0, -0.3, 0)  # Centered for portrait
DEFAULT_MODEL_SCALE = Vector3(1.5, 1.5, 1.5)  # Fills frame nicely
```

### Bottom Button
```gdscript
# BottomToggleButton
- Position: Bottom center
- Size: 200x50 pixels
- Text: "Toggle HUD ☰"
- Signal: pressed → _on_bottom_toggle_pressed()
```

## Migration Notes

### From Landscape to Portrait

**Before (Landscape):**
- 1280x720 (16:9)
- Sidebar on right
- Horizontal layout

**After (Portrait):**
- 720x1280 (9:16)
- Sidebar toggleable
- Vertical layout
- Bottom button for control

### Backwards Compatibility

Users can still change to landscape if desired:
1. Open Project Settings
2. Go to Display → Window
3. Change viewport dimensions
4. Swap width/height values

However, portrait is recommended for modern VTubing.

## Future Enhancements

Potential improvements:
- **Auto-rotation** - Detect device orientation
- **Landscape mode toggle** - Quick switch in settings
- **Adaptive layout** - Different layouts per orientation
- **Gesture controls** - Swipe to toggle sidebar
- **Picture-in-Picture** - For multitasking

## Conclusion

Portrait mode makes VRMVTube perfect for mobile VTubing and modern vertical video platforms. The centered character, clean layout, and easy controls create a professional mobile-first experience.
