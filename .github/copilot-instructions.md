# GitHub Copilot Instructions for VRMVTube

## Project Overview

VRMVTube is a cross-platform VTubing application built with Godot 4.3+ that uses VRM avatars for real-time animation. The project is designed to work on Windows, macOS, Linux, Android, and Web platforms.

## Code Style and Conventions

### GDScript Style
- Use 4 spaces for indentation (never tabs)
- Use snake_case for variables and functions
- Use PascalCase for class names
- Add type hints to all variables and function parameters
- Keep functions focused and under 50 lines when possible
- Add docstrings to complex functions

Example:
```gdscript
func load_vrm_model(file_path: String) -> bool:
    """Load a VRM model from the specified file path."""
    if not FileAccess.file_exists(file_path):
        push_error("VRM file not found: " + file_path)
        return false
    
    # Load model logic here
    return true
```

### Project Structure
```
vrmvtube/
├── addons/              # Third-party Godot addons
│   ├── vrm/            # VRM importer (from godot-vrm)
│   └── Godot-MToon-Shader/  # MToon shader
├── scenes/             # Godot scene files (.tscn)
├── scripts/            # GDScript files (.gd)
├── assets/             # Images, fonts, UI assets
├── models/             # Example VRM models (if any)
├── third_party/        # Git submodules for dependencies
└── .github/
    └── workflows/      # CI/CD workflows
```

## Development Guidelines

### Adding New Features
1. Create feature branches from main
2. Follow the existing code style
3. Update README.md if adding user-facing features
4. Test on multiple platforms when possible
5. Update the roadmap in README.md

### Dependencies
- **godot-vrm**: Added as git submodule in `third_party/godot-vrm`
- Copy needed addons from submodule to `addons/` directory
- Always credit dependencies in README.md with proper license information

### Platform-Specific Code
When writing platform-specific code, use Godot's built-in platform detection:

```gdscript
if OS.get_name() == "Windows":
    # Windows-specific code (e.g., virtual camera)
    pass
elif OS.get_name() == "Linux":
    # Linux-specific code
    pass
elif OS.get_name() == "macOS":
    # macOS-specific code
    pass
```

### Virtual Camera Support
- Virtual camera is ONLY available on Windows and Linux
- Always check platform before enabling virtual camera features
- Provide clear error messages on unsupported platforms

## Testing

### Manual Testing
Before committing changes:
1. Test in Godot Editor
2. Export for at least one target platform
3. Verify VRM models load correctly
4. Check for console errors

### CI/CD
- All platforms are built automatically via GitHub Actions
- Check workflow status before merging PRs
- Builds are triggered on push and pull requests

## License Compliance

### Critical Rules
1. **Always** credit dependencies in README.md
2. **Always** include original copyright notices
3. **Never** remove license files from dependencies
4. Keep MIT license notices for godot-vrm and MToon shader
5. This project is CC0, but dependencies retain their licenses

### When Adding Dependencies
1. Check the license of the dependency
2. Add credit to README.md under "Credits and Licenses"
3. Include copyright notice and license type
4. If using as submodule, document in README
5. If copying code, preserve original license headers

## Common Tasks

### Adding a New Scene
1. Create scene in `scenes/` directory
2. Create corresponding script in `scripts/` directory
3. Use clear, descriptive names (e.g., `vrm_viewer.tscn`, `vrm_viewer.gd`)

### Adding a VRM Model Feature
1. Check godot-vrm documentation for available APIs
2. Use the VRM importer plugin's methods
3. Handle errors gracefully (models may be invalid)
4. Support both VRM 0.x and 1.0 formats

### Updating godot-vrm Submodule
```bash
cd third_party/godot-vrm
git pull origin master
cd ../..
git add third_party/godot-vrm
git commit -m "Update godot-vrm submodule"
```

Then copy updated addons:
```bash
cp -r third_party/godot-vrm/addons/vrm addons/
cp -r third_party/godot-vrm/addons/Godot-MToon-Shader addons/
```

## Performance Guidelines

- Optimize for web export (keep memory usage low)
- Use object pooling for frequently created/destroyed objects
- Profile before optimizing (use Godot's built-in profiler)
- Keep draw calls minimal
- Test on lower-end devices for Android builds

## Security Considerations

- Validate all file paths before loading
- Sanitize user input
- Don't trust VRM files (they could be malformed)
- Use proper error handling
- Don't expose sensitive file system paths

## Accessibility

- Provide keyboard shortcuts for all actions
- Support different screen sizes and aspect ratios
- Provide clear error messages
- Include tooltips for UI elements

## Documentation

- Update README.md for user-facing changes
- Add code comments for complex algorithms
- Keep this file updated with new conventions
- Document platform-specific limitations

## Getting Help

- Check Godot documentation: https://docs.godotengine.org/
- Check godot-vrm README: https://github.com/V-Sekai/godot-vrm
- VRigUnity for feature ideas: https://github.com/Kariaro/VRigUnity
- Open GitHub issues for bugs or questions

## Commit Message Format

Use conventional commits format:
```
type(scope): description

feat(vrm): add VRM 1.0 support
fix(camera): resolve virtual camera crash on Linux
docs(readme): update installation instructions
ci(android): add Android build to workflow
```

Types: feat, fix, docs, style, refactor, test, ci, chore

## Review Checklist

Before submitting PR:
- [ ] Code follows style guidelines
- [ ] All dependencies are properly credited
- [ ] Changes are tested locally
- [ ] README.md is updated if needed
- [ ] No hardcoded paths or secrets
- [ ] Platform compatibility is maintained
- [ ] Virtual camera limitations are respected
- [ ] License compliance is maintained
