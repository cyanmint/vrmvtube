# Development Guide

This guide covers development practices and architecture for VRMVTube.

## Architecture Overview

VRMVTube is built on Godot Engine 4.6 and uses two main plugins:

1. **godot-vrm** - VRM model import/export and rendering
2. **GDMP** - MediaPipe integration for motion tracking

### Project Structure

```
vrmvtube/
├── addons/                    # Third-party plugins
│   ├── vrm/                   # VRM support
│   ├── Godot-MToon-Shader/    # MToon shader
│   └── GDMP/                  # MediaPipe integration
├── assets/                    # Game assets
│   └── models/                # VRM models
├── scenes/                    # Godot scenes
│   └── main.tscn             # Main application scene
├── scripts/                   # GDScript files
│   └── main.gd               # Main application logic
├── docs/                      # Documentation
└── .github/                   # GitHub configuration
    └── workflows/             # CI/CD workflows
```

## Key Components

### Main Scene (`scenes/main.tscn`)

The main UI scene contains:
- Control nodes for UI layout
- SubViewport for 3D rendering
- Camera and lighting for VRM display
- Buttons for user interaction

### Main Script (`scripts/main.gd`)

Core functionality:
- VRM model loading
- MediaPipe tracking initialization
- UI event handling
- Plugin detection and validation

### VRM Integration

Using the godot-vrm addon:
```gdscript
# Load VRM model
var gltf_document = GLTFDocument.new()
var gltf_state = GLTFState.new()
var error = gltf_document.append_from_file(vrm_path, gltf_state)
if error == OK:
    var scene = gltf_document.generate_scene(gltf_state)
    # Add to scene tree
```

### MediaPipe Integration

Using GDMP for tracking:
```gdscript
# Initialize hand tracking
# TODO: Implementation details to be added
```

## Development Workflow

### 1. Setup Development Environment

```bash
# Clone repository
git clone https://github.com/cyanmint/vrmvtube.git
cd vrmvtube

# Open in Godot
godot --editor .
```

### 2. Enable Plugins

1. Open Project Settings → Plugins
2. Enable "VRM" plugin
3. Enable "GDMP" plugin (when binaries are available)
4. Enable "Godot-MToon-Shader" plugin

### 3. Testing Changes

```bash
# Run project
godot --path . scenes/main.tscn

# Run headless for testing
godot --headless --check-only --path .
```

### 4. Building Exports

See [building.md](building.md) for platform-specific build instructions.

## Adding New Features

### Adding VRM Features

1. Check godot-vrm documentation
2. Use GLTFDocument and VRM extensions
3. Test with multiple VRM models (0.0 and 1.0)

### Adding Tracking Features

1. Check GDMP documentation
2. Use MediaPipe tasks appropriately
3. Test with different lighting/camera conditions

### Adding UI Features

1. Use Godot's Control nodes
2. Follow Material Design principles
3. Test on different screen resolutions

## Debugging

### Common Issues

**VRM Plugin Not Detected:**
- Verify addon is in `addons/vrm/`
- Enable plugin in Project Settings
- Restart Godot editor

**GDMP Not Working:**
- Check if binaries are present in `addons/GDMP/bin/`
- Download from GDMP releases if missing
- Verify platform compatibility

**Build Failures:**
- Check export templates are installed
- Verify export_presets.cfg is configured
- Check platform-specific requirements

### Debug Output

Enable verbose logging:
```gdscript
print("Debug: ", variable_name)
push_warning("Warning message")
push_error("Error message")
```

## Performance Optimization

### VRM Rendering

- Use LOD (Level of Detail) for models
- Optimize shader complexity
- Limit bone count when possible

### Tracking

- Reduce camera resolution if needed
- Adjust MediaPipe model complexity
- Use frame skipping for lower-end devices

## Code Quality

### Style Guide

Follow Godot GDScript style guide:
- 4 spaces for indentation (not tabs)
- snake_case for variables and functions
- PascalCase for classes
- CONSTANT_CASE for constants

### Type Safety

Always use type hints:
```gdscript
var count: int = 0
var name: String = "VRMVTube"

func process_data(input: Array) -> Dictionary:
    return {}
```

### Error Handling

Check for errors and handle gracefully:
```gdscript
var file = FileAccess.open(path, FileAccess.READ)
if file == null:
    push_error("Failed to open file: " + path)
    return
# Use file
file.close()
```

## Testing

### Manual Testing Checklist

- [ ] VRM model loads successfully
- [ ] UI is responsive
- [ ] Buttons work correctly
- [ ] Camera tracking initializes
- [ ] No console errors
- [ ] Performance is acceptable

### Platform Testing

Test on all target platforms:
- [ ] Windows (x64)
- [ ] Linux (x64)
- [ ] macOS (x64/ARM)
- [ ] Android (ARM)
- [ ] Web (HTML5)

## Documentation

Update documentation when:
- Adding new features
- Changing APIs
- Fixing bugs that affect usage
- Modifying build process

## Resources

- [Godot Documentation](https://docs.godotengine.org/)
- [VRM Specification](https://github.com/vrm-c/vrm-specification)
- [godot-vrm](https://github.com/V-Sekai/godot-vrm)
- [GDMP](https://github.com/j20001970/GDMP)
- [MediaPipe](https://developers.google.com/mediapipe)

## Support

- GitHub Issues: Bug reports and feature requests
- GitHub Discussions: Questions and community support
- Check existing issues before creating new ones
