# VRM Shader/Material Loading Fix

## Issue
VRM models were loading without proper colors and textures, appearing completely white or grayscale. This affected both the default model and any newly imported VRM models.

## Root Causes

1. **Material Instance Sharing**: Original materials were being referenced rather than duplicated, preventing proper shader initialization
2. **Shader Compilation Timing**: Materials weren't being refreshed after the scene tree fully loaded
3. **Transparency/Alpha Issues**: Some VRM materials had incorrect alpha values
4. **Texture Assignment**: Textures weren't being properly assigned during runtime loading

## Solutions Implemented

### 1. Enhanced Material Refresh Function

Updated `_update_vrm_materials()` with multiple strategies:

```gdscript
# Strategy 1: Deep Duplicate Materials
var duplicated_material := material.duplicate(true)

# Strategy 2: Fix Visibility Settings
if duplicated_material is StandardMaterial3D:
    std_mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
    std_mat.albedo_color.a = 1.0  # Ensure full opacity

# Strategy 3: MToon Shader Parameter Fixes
if shader_mat.shader:
    # Check and fix alpha parameters
    for param in ["_alpha", "alpha", "_Alpha", "transparency"]:
        if current_val < 0.9:
            shader_mat.set_shader_parameter(param, 1.0)

# Strategy 4: Force Shader Recompilation
shader_mat.shader = null
shader_mat.shader = current_shader

# Strategy 5: Dual Material Assignment
mesh_instance.set_surface_override_material(i, duplicated_material)
mesh_instance.mesh.surface_set_material(i, duplicated_material)
```

### 2. Additional Frame Waits

Added extra frame processing time to ensure materials are fully loaded:

```gdscript
await get_tree().process_frame  # Scene tree processing
await get_tree().process_frame  # Material loading
_update_vrm_materials(current_vrm_instance)
await get_tree().process_frame  # Material refresh
```

### 3. Comprehensive Logging

Added detailed console output to track material updates:
- Mesh names being processed
- Shader types detected
- Parameter changes made
- Material class types

## How It Works

1. **Load Phase**: VRM model is instantiated and added to scene tree
2. **Processing Phase**: Multiple frames are waited to allow Godot to process the scene
3. **Material Refresh Phase**: 
   - Each mesh instance is found
   - Materials are deeply duplicated
   - Shader parameters are checked and fixed
   - Materials are applied both as overrides and direct assignments
4. **Verification Phase**: Console logs show which materials were processed

## Testing

To verify the fix:

1. Load the default VRM model (should show colors immediately)
2. Use "Load VRM Model" to import a new .vrm file
3. Check console output for material update messages
4. Model should display with proper colors, textures, and shading

## What This Fixes

✅ White/grayscale models now show colors
✅ Textures properly displayed
✅ MToon shader effects visible
✅ Works for both default and newly loaded models
✅ No manual reimport required

## What Still Requires Manual Action

⚠️ **First-time VRM import in Godot Editor**:
- New VRM files added to the project still need to be reimported once in the editor
- This is a Godot engine limitation for initial texture extraction
- After first reimport, runtime loading works with this fix

⚠️ **Plugin Requirements**:
- VRM plugin must be enabled
- MToon Shader plugin must be enabled
- Both are required for proper material handling

## Technical Details

### Material Types Handled

1. **StandardMaterial3D**:
   - Sets transparency to DISABLED
   - Ensures albedo alpha = 1.0
   - Uses per-pixel shading

2. **ShaderMaterial (MToon)**:
   - Checks multiple alpha parameter names
   - Forces shader recompilation
   - Preserves shader parameters

### Why Deep Duplicate?

Using `material.duplicate(true)` ensures:
- All sub-resources are copied
- Texture references are preserved
- Shader parameters are cloned
- No shared state between instances

### Why Dual Assignment?

Setting materials in two places:
1. `set_surface_override_material()` - Override for this instance
2. `mesh.surface_set_material()` - Mesh-level assignment

This ensures materials work regardless of Godot's rendering path.

## Future Improvements

Potential enhancements:
- Cache material duplicates to avoid redundant processing
- Add material quality settings
- Support for custom shader variants
- Automatic texture compression detection

## Related Files

- `scripts/main.gd` - Material refresh logic
- `scenes/main.tscn` - Scene lighting and environment
- `VRM_TEXTURE_MANUAL_REIMPORT.md` - First-time import guide
- `VRM_TEXTURES_FIX.md` - General troubleshooting

---

**Status**: This fix resolves runtime material loading issues. First-time imports still require manual reimport in Godot Editor (engine limitation).
