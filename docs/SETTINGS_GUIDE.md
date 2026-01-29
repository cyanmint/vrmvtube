# Settings Menu - User Guide

## Opening the Settings Menu

Click the **"Settings"** button in the right panel (below "Reset Pose" button).

## Settings Tabs

### 1. Model Tab

**Purpose:** Change the VRM model used for your avatar

**Options:**
- **Current Model Path:** Shows the currently loaded VRM model
- **Browse Button:** Opens file dialog to select a new .vrm file

**How to use:**
1. Click "Browse for VRM Model..."
2. Navigate to and select a .vrm file
3. Click "Apply" to load the model immediately
4. Click "Save" to make it the default model

**Note:** Model will be remembered and loaded automatically next time.

---

### 2. Background Tab

**Purpose:** Customize the background appearance

**Options:**
- **Background Type:** 
  - Solid Color (single color background)
  - Gradient (top to bottom gradient) - *Currently uses solid color*
  - Image (custom image background) - *Coming soon*

- **Solid Color:** Color picker for solid background
- **Gradient Colors:** Top and bottom color pickers for gradient

**How to use:**
1. Select background type from dropdown
2. Click color picker to choose color
3. Click "Apply" to preview
4. Click "Save" to keep the setting

**Current Behavior:**
- Solid Color: Works perfectly ✅
- Gradient: Uses top color only (needs custom shader)
- Image: Not yet implemented

---

### 3. Camera Tab

**Purpose:** Select webcam input for face tracking

**Options:**
- **Webcam Dropdown:** Lists available camera devices
- **Info:** Explains desktop webcam limitations

**Desktop Platforms (Windows/Mac/Linux):**
- Godot 4.x has limited webcam support on desktop
- Simulated tracking is used instead
- Real webcam support planned (MediaPipe/OpenCV)

**Mobile/Web Platforms:**
- Cameras auto-detected and listed
- Select from dropdown to choose camera

**How to use:**
1. Select camera from dropdown (if available)
2. Click "Apply" or "Save"
3. Note: Desktop platforms will continue using simulated tracking

---

### 4. About Tab

**Purpose:** Information about VRMVTube

**Content:**
- **Application name and version**
- **Credits:**
  - godot-vrm (V-Sekai) - VRM loading
  - MToon Shader - Anime-style rendering
  - Godot Engine - Framework
  - VRigUnity - Inspiration
- **License information** (CC0 1.0 Universal)
- **Platform support** (Windows, Mac, Linux, Android, Web)
- **Links:**
  - GitHub repository
  - VRM specification
  - Godot Engine

**How to use:**
- Scroll to read all information
- Click links to visit websites (if supported)

---

## Action Buttons

### Save Button
- **Applies** settings immediately
- **Saves** settings to config file
- **Persists** across sessions
- **Closes** settings window

**When to use:** When you want to keep your changes permanently

---

### Cancel Button
- **Discards** all changes
- **Restores** original settings
- **Closes** settings window

**When to use:** When you want to undo all changes made in this session

---

### Apply Button
- **Applies** settings immediately
- **Does NOT save** to file
- **Keeps window open**
- **Allows preview** before saving

**When to use:** When you want to test settings before committing

---

## Settings File

Settings are saved to: `user://vrmvtube_settings.cfg`

**Location by platform:**
- **Windows:** `%APPDATA%\Godot\app_userdata\VRMVTube\vrmvtube_settings.cfg`
- **Linux:** `~/.local/share/godot/app_userdata/VRMVTube/vrmvtube_settings.cfg`
- **macOS:** `~/Library/Application Support/Godot/app_userdata/VRMVTube/vrmvtube_settings.cfg`

**File Format:** INI-style config file

**Example:**
```ini
[model]
path="res://example/cyanmint.vrm"
recent_models=["res://models/model1.vrm", "res://models/model2.vrm"]

[background]
type="solid"
color=[0.2, 0.2, 0.25, 1.0]

[camera]
selected_index=0
device_name="Default Camera"
```

---

## Workflow Examples

### Example 1: Change Background Color

1. Click "Settings" button
2. Go to "Background" tab
3. Click on the color picker (Solid Color)
4. Choose your preferred color
5. Click "Apply" to see the change
6. If you like it, click "Save"
7. If not, adjust and "Apply" again
8. Click "Cancel" to revert if needed

### Example 2: Load a New Model

1. Click "Settings" button
2. Go to "Model" tab
3. Click "Browse for VRM Model..."
4. Select your .vrm file
5. Click "Select" in file dialog
6. Click "Apply" to load the model
7. Wait for model to load
8. Click "Save" to make it default

### Example 3: Preview Multiple Backgrounds

1. Click "Settings" button
2. Go to "Background" tab
3. Try first color → Click "Apply"
4. Try second color → Click "Apply"
5. Try third color → Click "Apply"
6. Once happy, click "Save"
7. Or click "Cancel" to keep original

---

## Keyboard Shortcuts

Currently none, but could be added:
- `Ctrl+S` - Save settings
- `Escape` - Cancel/Close
- `Ctrl+Enter` - Apply

---

## Troubleshooting

### Settings window doesn't open
- Check console for errors
- Verify settings_menu.tscn exists
- Check node paths in main.tscn

### Settings don't persist
- Check write permissions for user data folder
- Look for errors in console when saving
- Verify config file is created

### Model doesn't load after changing
- Make sure VRM file path is valid
- Check that VRM plugin is enabled
- See VRM_TEXTURES_FIX.md for texture issues

### Background color doesn't change
- Make sure you clicked "Apply" or "Save"
- Check that WorldEnvironment exists in scene
- Verify environment is properly set up

---

## Tips

1. **Always use Apply first** to preview changes before saving
2. **Recent models** are tracked (up to 10) for quick access
3. **Settings persist** across sessions automatically when saved
4. **Cancel is safe** - use it to experiment without consequences
5. **Background gradient** will be fully implemented in future updates

---

## Future Enhancements

Planned features for settings menu:

- [ ] Recent models list in Model tab
- [ ] Gradient background with custom shader
- [ ] Image background support
- [ ] Real webcam selection (when supported)
- [ ] Tracking sensitivity settings
- [ ] Performance/quality presets
- [ ] Keyboard shortcut customization
- [ ] Export/Import settings
- [ ] Reset to defaults button

---

**For more help:** See `TROUBLESHOOTING.md`, `QUICKSTART.md`, or `README.md`
