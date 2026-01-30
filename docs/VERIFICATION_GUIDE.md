# VRMVTube UI Verification Guide

## How to Verify the New HUD Overlay Design

This guide explains how to verify that all requirements have been successfully implemented.

## Prerequisites

- Godot Engine 4.6 installed
- VRMVTube repository cloned
- Display server available (X11 or Wayland)

## Verification Steps

### Step 1: Open the Project

```bash
cd vrmvtube
godot --path . --editor
```

Or double-click `project.godot` in Godot Project Manager.

### Step 2: Run the Scene

1. Open `scenes/main.tscn` in the editor
2. Press F5 or click the "Run" button
3. The application window should appear

### Step 3: Verify Green Background

**What to Check:**
- The 3D viewport (left side) should have a **bright green background**
- Color should be pure green (#00FF00 / RGB 0, 255, 0)
- No VRM model will be visible initially (not loaded yet)

**Visual Confirmation:**
```
┌────────────────────┬──────────┐
│                    │          │
│   BRIGHT GREEN     │   HUD    │
│   BACKGROUND       │          │
│   (No model yet)   │          │
│                    │          │
└────────────────────┴──────────┘
```

**How to Test in Godot Editor:**
1. In Scene tree, navigate to: `Main > ContentContainer > ViewportContainer > SubViewport > WorldEnvironment`
2. Select the WorldEnvironment node
3. In the Inspector, check `Environment` property
4. Expand it and verify:
   - Background Mode: Color
   - Background Color: (0, 1, 0) which is green

### Step 4: Verify HUD Structure

**What to Check:**
- Right side panel should be visible
- Panel should have "VRMVTube" title at top
- Collapse button (◀) should be next to title

**Visual Confirmation:**
```
Right side should show:
┌─────────────────────┐
│ VRMVTube        ◀  │ ← Header
├─────────────────────┤
│ VTuber Application  │ ← Product Info
│ with VRM and...     │
├─────────────────────┤
│ Model Management    │ ← Section Header
│ [Load VRM Model]    │ ← Button
├─────────────────────┤
│ Tracking Controls   │ ← Section Header
│ [Start Tracking]    │ ← Button
│ ┌─────────────────┐ │
│ │ Camera Preview  │ │ ← Camera area
│ └─────────────────┘ │
├─────────────────────┤
│ Settings            │ ← Section Header
│ [Mode: Move]        │
│ Camera Controls     │
│ ... (controls)      │
└─────────────────────┘
```

**How to Verify in Scene Tree:**
```
Main
└── ContentContainer
    ├── ViewportContainer (left, expands)
    └── HUDOverlay (right, 400px)
        └── VBoxContainer
            ├── Header
            │   ├── TitleLabel
            │   └── CollapseButton
            └── ScrollContainer
                └── ContentVBox
                    ├── InfoSection
                    ├── ModelSection
                    ├── TrackingSection
                    ├── SettingsSection
                    └── StatusSection
```

### Step 5: Test HUD Scrolling

**What to Check:**
- Scroll wheel should work in HUD area
- Content should scroll up/down
- Scroll bar should appear if content is longer than window

**How to Test:**
1. Move mouse over HUD panel (right side)
2. Scroll mouse wheel up and down
3. Observe content moving

**Expected Behavior:**
- Content scrolls smoothly
- All sections remain accessible
- Scroll bar visible if needed

### Step 6: Test HUD Collapse

**What to Check:**
- Clicking collapse button should hide/show HUD content
- Button icon should change between ◀ and ▶
- HUD width should change between 400px and 50px

**How to Test:**
1. Click the ◀ button in HUD header
2. Observe HUD collapsing to thin vertical strip
3. Button should change to ▶
4. Viewport should expand to fill the space
5. Click ▶ button to expand again
6. HUD should return to full width
7. Button should change back to ◀

**Expected Behavior:**

Collapsed State:
```
┌──────────────────────┬─┐
│                      │V│ ← Thin strip
│   GREEN VIEWPORT     │R│
│   (More space)       │M│
│                      │V▶│ ← Expand button
└──────────────────────┴─┘
```

Expanded State:
```
┌────────────┬─────────────┐
│            │ VRMVTube ◀ │ ← Normal width
│  GREEN     │  (Content)  │
│  VIEWPORT  │  (Content)  │
│            │  (Content)  │
└────────────┴─────────────┘
```

### Step 7: Verify All Buttons Moved to HUD

**What to Check:**
- "Load VRM Model" button should be in Model Section
- "Start Tracking" button should be in Tracking Section
- No buttons should be outside the HUD panel
- No buttons at top of window

**Location Check:**
```
✅ Load VRM Model → In HUD > ModelSection
✅ Start Tracking → In HUD > TrackingSection
❌ Buttons at top → Should NOT exist
```

**How to Verify:**
1. Look at the top of the application window
2. Should see only green viewport (left) and HUD (right)
3. No title bar, no buttons at top
4. All controls should be inside HUD panel

### Step 8: Verify Product Info Moved to HUD

**What to Check:**
- "VRMVTube" title should be in HUD header (not at top of window)
- Product description should be in InfoSection
- Font size should be appropriate (24pt for title, normal for description)

**Text to Find:**
```
Title (in HUD header):
"VRMVTube"

Description (in InfoSection):
"VTuber Application with VRM and MediaPipe Support
Powered by Godot Engine 4.6"
```

**How to Verify:**
1. Check top of window - should NOT have separate title
2. Check HUD header - should have "VRMVTube" title
3. Scroll to top of HUD content - should see product description

### Step 9: Test Button Functionality

**What to Check:**
- Buttons should still work in their new locations
- Load VRM Model button opens file dialog
- Start Tracking button attempts to start tracking

**How to Test:**

**Load VRM Model:**
1. Click "Load VRM Model" button in ModelSection
2. File dialog should open
3. Select a .vrm file (if you have one)
4. Model should load in green viewport

**Start Tracking:**
1. Click "Start Tracking" button in TrackingSection
2. Should see status message (may show MediaPipe not available)
3. Camera preview should update if tracking works

### Step 10: Verify Clean Viewport

**What to Check:**
- Left side should ONLY show 3D viewport
- No UI elements should overlap the viewport
- No title, buttons, or status in viewport area
- Just green background (and VRM model if loaded)

**Visual Check:**
```
Left Side (Viewport):
┌────────────────────┐
│                    │ ← No UI elements
│   GREEN            │ ← Just green background
│   BACKGROUND       │ ← Or VRM model if loaded
│                    │ ← Clean, uncluttered
└────────────────────┘
```

## Expected Test Results

### ✅ All Requirements Met

1. ✅ **Product info in HUD** - Title and description in HUD panel
2. ✅ **Model management in HUD** - Load VRM button in HUD
3. ✅ **Start tracking in HUD** - Tracking button in HUD  
4. ✅ **HUD scrollable** - Mouse wheel scrolls HUD content
5. ✅ **HUD foldable** - Collapse button works (◀/▶)
6. ✅ **Green background** - Viewport shows #00FF00
7. ✅ **VRigUnity-style** - Clean viewport with overlay

### Visual Confirmation Checklist

Use this checklist when verifying:

- [ ] Application opens without errors
- [ ] Green background visible in viewport
- [ ] HUD panel visible on right side
- [ ] VRMVTube title in HUD header
- [ ] Product info in HUD content
- [ ] Load VRM Model button in HUD
- [ ] Start Tracking button in HUD
- [ ] Camera preview in HUD
- [ ] Settings controls in HUD
- [ ] Status label in HUD
- [ ] HUD scrolls with mouse wheel
- [ ] Collapse button works (◀/▶)
- [ ] HUD expands/collapses correctly
- [ ] Viewport has no UI overlay
- [ ] Viewport fills left side
- [ ] No title/buttons at top of window

## Screenshot Locations (if captured)

If you take screenshots for documentation:

```
screenshots/
├── 01_green_viewport.png         - Shows green background
├── 02_hud_expanded.png            - Shows full HUD panel
├── 03_hud_collapsed.png           - Shows collapsed HUD
├── 04_hud_scrolling.png           - Shows scrollable content
├── 05_full_application.png        - Shows complete UI
└── 06_vrm_model_loaded.png        - Shows model on green
```

## OBS Studio Verification (Optional)

To verify the green chroma key works for streaming:

1. Open OBS Studio
2. Add "Window Capture" source
3. Select VRMVTube window
4. Right-click source → Filters
5. Add "Chroma Key" filter
6. Select green as key color
7. Background should be removed, showing only VRM model

**Expected Result:**
- Green background removed
- VRM model visible
- HUD remains visible (or can be collapsed)
- Perfect for streaming overlay

## Troubleshooting

### Green Background Not Showing

**Check:**
1. WorldEnvironment node exists in SubViewport
2. Environment resource is created
3. Background Mode is set to Color
4. Background Color is (0, 1, 0)

**Fix:**
- Run the application once to trigger setup_viewport()
- Check console for any errors
- Verify scripts/main.gd has green background code

### HUD Not Visible

**Check:**
1. HUDOverlay node exists in ContentContainer
2. HUD is not collapsed by default
3. No errors in console

**Fix:**
- Open scenes/main.tscn in editor
- Check HUDOverlay visibility
- Verify custom_minimum_size is set

### Buttons Not Working

**Check:**
1. Signal connections exist in scene file
2. Correct node paths in connections
3. No errors when clicking buttons

**Fix:**
- Reconnect signals in editor
- Check console output when clicking
- Verify method names in main.gd

### Scrolling Not Working

**Check:**
1. ScrollContainer exists in HUD
2. ContentVBox is child of ScrollContainer
3. Content is tall enough to scroll

**Fix:**
- Verify ScrollContainer in scene tree
- Check size_flags_vertical is set
- Add more content to test scrolling

## Conclusion

If all checks pass, the implementation is successful! The application now has:

- Clean, professional VTubing interface
- Green chroma key background
- All UI consolidated in HUD overlay
- Scrollable and collapsible controls
- VRigUnity-style layout

Perfect for live streaming and VTuber content creation! 🎉
