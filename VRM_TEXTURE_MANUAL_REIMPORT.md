# VRM Texture Issue - Critical Information

## Issue: VRM Model Shows White/Grayscale (No Colors)

The VRM model appears completely white or grayscale without proper skin tones, hair colors, or clothing textures.

### Root Cause

This is **NOT a code bug** - it's a **Godot import limitation**. VRM files contain embedded textures that Godot must extract during import. If textures don't import properly, the model renders with default white materials.

### Why This Happens

1. **First-time import**: When you add a .vrm file to the project, Godot doesn't automatically extract embedded textures
2. **Missing MToon shader**: The VRM format uses MToon shader for anime-style rendering
3. **Import cache issues**: Sometimes the .import cache gets corrupted

### SOLUTION (Required User Action)

**You MUST do this in the Godot Editor:**

1. **Open Godot 4.3+ Editor**
2. **Find the VRM file** in FileSystem dock (e.g., `example/cyanmint.vrm`)
3. **Right-click on the .vrm file**
4. **Select "Reimport"**
5. **In the Import dock** (bottom panel):
   - Verify import settings
   - Check that textures are enabled
6. **Click "Reimport" button**
7. **Wait for reimport to complete** (may take 10-30 seconds)
8. **Close and reopen the scene** (or press F6 to reload)

### Verify Plugins Are Enabled

**Project → Project Settings → Plugins:**
- ✅ **VRM** plugin - MUST be enabled
- ✅ **MToon Shader** plugin - MUST be enabled (CRITICAL for textures!)

If either is disabled:
1. Enable both plugins
2. Click OK
3. **Restart Godot completely**
4. Reimport the VRM file (steps above)

### What the Code Does

The code includes material refresh logic:
```gdscript
func _update_vrm_materials(node: Node) -> void:
    # Forces material refresh after loading
```

However, this **cannot fix** missing imports. It only refreshes already-loaded materials.

### Expected Result After Reimport

✅ Colored skin tones (not white/gray)
✅ Colored hair
✅ Colored clothing
✅ Proper textures and details
✅ Anime-style shading (MToon effect)

### If It Still Doesn't Work

1. **Check Console** for texture loading errors
2. **Try a different VRM model** to verify the issue
3. **Export the VRM again** from VRoid Studio or UniVRM
4. **Delete .godot/imported folder** and reimport everything
5. **Update Godot** to latest 4.3+ stable version

### Alternative: Use Pre-Imported VRM

If you have access to a Unity project with UniVRM:
1. Import the VRM in Unity
2. Use UniVRM to export it again
3. This sometimes fixes compatibility issues

### Why We Can't Auto-Fix This

- Godot's import system runs in the editor only
- Runtime code cannot trigger reimports
- Texture extraction requires editor tools
- This is a Godot engine limitation, not a code bug

### Technical Details

**What's in a VRM file:**
- 3D model geometry (meshes, bones)
- Textures (embedded as binary data)
- Materials (MToon shader properties)
- Metadata (author, license, etc.)

**Import process:**
1. Godot reads the .vrm file
2. Extracts textures to `.godot/imported/`
3. Creates material resources
4. Generates .import file with settings

If step 2 fails, you get white materials.

---

**Bottom Line:** This requires manual action in Godot Editor. The code cannot fix it automatically.

See also: `VRM_TEXTURES_FIX.md` for detailed troubleshooting steps.
