# VRM Texture Issues - Troubleshooting

## Issue: VRM Model Shows White/Gray Without Textures

If the VRM model loads but appears without proper colors/textures (all white or gray), follow these steps:

### Solution 1: Re-import VRM Model in Godot Editor

1. **Open Godot Editor**
2. **Find the VRM file** in the FileSystem panel (e.g., `example/cyanmint.vrm`)
3. **Right-click on the .vrm file** → Select **"Reimport"**
4. **In the Import dock** (bottom panel), ensure:
   - All texture options are checked
   - Materials are set to import
   - MToon shader is recognized
5. **Click "Reimport"**
6. **Restart the scene** (close and reopen, or press F6)

### Solution 2: Verify MToon Shader Plugin

1. Go to **Project → Project Settings → Plugins**
2. Ensure **BOTH** plugins are enabled:
   - ✅ **VRM** plugin
   - ✅ **MToon Shader** plugin (CRITICAL for textures!)
3. If not enabled, enable them
4. **Restart Godot completely**
5. Re-import the VRM model (see Solution 1)

### Solution 3: Check Renderer Compatibility

The project uses GL Compatibility renderer for cross-platform support. This should work with VRM textures, but if issues persist:

1. **Project Settings → Rendering → Rendering Method**
2. Try changing to **"forward_plus"** (better quality, desktop-only)
3. Restart and reload the model

Note: This will break web/mobile compatibility, so only use for testing.

### Solution 4: Convert VRM File

If the VRM file is corrupted or incompatible:

1. **Open the VRM in VRoid Studio** or **UniVRM (Unity)**
2. **Export it again** as a new .vrm file
3. Try loading the new file in VRMVTube

### Solution 5: Check VRM Format

- VRMVTube supports both **VRM 0.x** and **VRM 1.0** formats
- Some older VRM files may have compatibility issues
- Try exporting from VRoid Studio with latest VRM format

## Technical Details

### Why This Happens

1. **Godot Import System**: VRM files are packaged scenes with embedded textures. Godot needs to extract and import these textures properly.

2. **MToon Shader**: VRM models use MToon shader for anime-style rendering. Without this shader, materials fall back to default (white/gray).

3. **Import Cache**: Sometimes Godot's import cache gets corrupted, requiring a fresh import.

### What the Code Does

The updated `main.gd` includes:

```gdscript
func _update_vrm_materials(node: Node) -> void:
    """Force material refresh on all meshes"""
    if node is MeshInstance3D:
        for i in range(mesh.get_surface_count()):
            var material := mesh.surface_get_material(i)
            if material:
                # Trigger material update
                mesh_instance.set_surface_override_material(i, material)
```

This forces Godot to refresh materials after loading, but it won't fix missing imports.

## Expected Result

After proper import, you should see:
- ✅ Colored skin tones
- ✅ Colored hair
- ✅ Colored clothing
- ✅ Proper textures and details
- ✅ Anime-style shading (if MToon is working)

## Still Not Working?

If textures still don't show after all steps:

1. **Check Console Output** - Look for texture loading errors
2. **Check the VRM file** - Open it in VRoid Studio to verify it's valid
3. **Try a different VRM model** - Test with a known-good VRM file
4. **Report the issue** - Include:
   - Godot version
   - VRM file source
   - Console error messages
   - Screenshot showing the issue

---

**Related Files:**
- `scripts/main.gd` - Material update code
- `TROUBLESHOOTING.md` - General troubleshooting
- `project.godot` - Renderer and plugin settings
