# External VRM Model Loading Fix

## Problem
When users clicked "Load VRM Model" and selected VRM files from their computer, the app showed only a green background with the error message "Error: Failed to load VRM model".

## Root Cause
The original code used Godot's `load(path)` function which **only works for res:// paths** (resources within the Godot project). External file paths from the file dialog would return `null`, causing the loading to fail silently.

## Solution
Implemented a **dual-path loading strategy**:

### 1. Internal Resources (res:// paths)
Use standard `load()` function for files within the project:
```gdscript
if path.begins_with("res://"):
    var packed_scene = load(path)
    if packed_scene != null:
        loaded_scene = packed_scene.instantiate()
```

### 2. External Files (absolute paths)
Use **runtime GLTFDocument import** for files from user's computer:
```gdscript
else:
    loaded_scene = _load_vrm_runtime(path)
```

## Runtime VRM Loading

The new `_load_vrm_runtime()` function:

1. **Creates GLTF Document and State**
   ```gdscript
   var gltf := GLTFDocument.new()
   var state := GLTFState.new()
   ```

2. **Registers VRM Extension** (critical!)
   ```gdscript
   var vrm_extension = vrm_extension_script.new()
   gltf.register_gltf_document_extension(vrm_extension, true)
   ```

3. **Configures Binary Image Handling**
   ```gdscript
   state.handle_binary_image = GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED
   ```

4. **Loads File**
   ```gdscript
   var error := gltf.append_from_file(path, state, 0)
   ```

5. **Generates Scene**
   ```gdscript
   var generated_scene := gltf.generate_scene(state)
   ```

6. **Cleans Up**
   ```gdscript
   gltf.unregister_gltf_document_extension(vrm_extension)
   ```

## Why This Works

### VRM Format
- VRM is built on GLTF 2.0 format
- Contains embedded textures, materials, and metadata
- Requires GLTF parsing for runtime loading

### GLTFDocument
- Can load from **any file path** at runtime
- Not limited to res:// like `load()` function
- Supports GLTF extensions (including VRM)
- Same method used by VRM addon's editor importer

### VRM Extension Registration
Critical for proper VRM support:
- Processes VRM-specific metadata
- Handles blend shape mappings (expressions)
- Configures materials correctly
- Applies VRM avatar settings

## What Now Works

✅ Load VRM models from anywhere on computer
✅ File dialog for browsing .vrm files
✅ Absolute paths work (C:/Users/..., /home/...)
✅ Internal res:// paths still supported
✅ Proper error messages
✅ All VRM features preserved (blend shapes, materials, etc.)
✅ Colors and textures display correctly
✅ No manual reimport needed for external files

## Usage

1. **Click "Load VRM Model" button**
2. **Browse to any .vrm file on your computer**
3. **Select the file**
4. **Model loads automatically with textures**
5. **Face tracking works immediately**

## Technical Details

### File Path Detection
```gdscript
if path.begins_with("res://"):
    # Project resource
else:
    # External file
```

### Error Handling
- File existence check before loading
- GLTF parsing error detection
- Scene generation validation
- User-friendly error messages

### Performance
- **First load**: Slower (runtime parsing)
- **Subsequent loads**: Same model loads fast
- **res:// paths**: Cached, very fast

## Known Limitations

⚠️ **Large files**: May take a few seconds to parse
⚠️ **MToon Shader**: Plugin must be enabled for materials
⚠️ **Memory**: External files not unloaded until scene restart

✅ **No reimport needed**: Everything handled at runtime
✅ **No copying files**: Loads directly from source
✅ **All VRM features**: Full support maintained

## Debugging

### If Model Still Doesn't Load

1. **Check console for errors**
   ```
   "Failed to parse VRM file: [error code]"
   "Failed to generate scene from VRM file"
   ```

2. **Verify VRM plugin is enabled**
   - Project → Project Settings → Plugins
   - "VRM" should be checked ✅

3. **Verify MToon Shader plugin is enabled**
   - Project → Project Settings → Plugins
   - "MToon Shader" should be checked ✅

4. **Check file format**
   - Must be .vrm file (VRM 0.x or 1.0)
   - Valid GLTF structure
   - Not corrupted

5. **Check file path**
   - No special characters causing issues
   - File still exists at that location
   - Read permissions granted

## Code Reference

See `scripts/main.gd`:
- Line ~112: `_load_vrm_model()` - Main loading function
- Line ~254: `_load_vrm_runtime()` - Runtime import function

Based on `addons/vrm/import_vrm.gd`:
- Line ~28: `_import_scene()` - Editor import process (template for runtime)

## Related Fixes

This fix works together with:
- **Material loading fix** (commit 7f4c95c): Ensures textures display
- **Shader refresh** (commit 7f4c95c): Forces shader recompilation
- **Default scaling** (commit 22b6cf2): Models appear properly sized

---

**Status: RESOLVED** ✅

External VRM models now load correctly from any location on the user's computer!
