# GitHub Copilot Development Instructions for VRMVTube

## Project Overview
VRMVTube is a VTuber application built with Godot Engine 4.6 stable that combines:
- **VRM model support** via V-Sekai/godot-vrm addon
- **MediaPipe hand/face tracking** via j20001970/GDMP addon
- Inspired by Kariaro/VRigUnity but implemented entirely in Godot

## Development Guidelines

### 1. Code Quality
- Follow GDScript style guide
- Use type hints for all variables and function parameters
- Add comments for complex logic
- Keep functions small and focused (single responsibility)
- Use meaningful variable and function names

### 2. Testing Requirements
- **ALWAYS test building** before committing code
- Test on multiple platforms when possible
- Verify VRM model loading works correctly
- Test MediaPipe tracking functionality
- Check UI responsiveness

### 3. License Compliance
- **All code must respect MIT License terms**
- Properly attribute all third-party code and libraries
- Include license notices in LICENSES.md or docs/licenses.md
- Credit sources when copy-pasting code

### 4. Dependencies
Current dependencies and their licenses:
- **godot-vrm** (MIT) - VRM import/export, MToon shader
- **GDMP** (MIT) - MediaPipe integration for Godot
- **MediaPipe** (Apache 2.0) - Google's ML framework
- Inspired by **VRigUnity** (MIT) - reference implementation

### 5. Platform Support
Target platforms (in priority order):
1. Windows (x86_64)
2. Linux (x86_64)
3. macOS (x86_64, arm64)
4. Android (arm64-v8a, armeabi-v7a)
5. Web (HTML5/WebAssembly)

### 6. CI/CD
- Use GitHub Actions for automated builds
- Build artifacts for all target platforms
- Run tests before deployment
- Generate release builds automatically

### 7. File Organization
```
vrmvtube/
├── addons/              # Godot plugins (vrm, GDMP)
├── assets/              # Game assets (models, textures, etc.)
├── scenes/              # Godot scene files
├── scripts/             # GDScript files
├── docs/                # Documentation
├── .github/             # GitHub-specific files
│   ├── workflows/       # CI/CD workflows
│   └── copilot-instructions.md
├── project.godot        # Godot project file
└── export_presets.cfg   # Export configurations
```

### 8. VRM Integration
- Use V-Sekai/godot-vrm addon for VRM support
- Support VRM 0.0 and VRM 1.0 models
- Implement proper MToon shader rendering
- Handle VRM metadata and licenses

### 9. MediaPipe Integration
- Use GDMP for MediaPipe functionality
- Implement hand tracking for VRM hand bones
- Consider face tracking for facial expressions
- Optimize performance for real-time tracking

### 10. Building Instructions
- Document build process clearly
- Provide platform-specific build instructions
- Include dependency installation steps
- Test build instructions on clean environment

### 11. Version Control
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Write clear, descriptive commit messages
- Keep commits atomic and focused
- Don't commit build artifacts or large binaries

### 12. Documentation
- Keep README.md up-to-date
- Document all public APIs
- Provide usage examples
- Include screenshots and demos

## Quick Reference

### Adding New Features
1. Create feature branch
2. Implement with tests
3. Test on target platforms
4. Update documentation
5. Submit PR with clear description

### Before Every Commit
- [ ] Code tested locally
- [ ] No lint errors
- [ ] Documentation updated
- [ ] Licenses verified
- [ ] Build successful

### Common Commands
```bash
# Build for specific platform
godot --export-release "Platform Name" output_path

# Run headless tests
godot --headless --script test_script.gd

# Check project
godot --check-only --headless
```

## Resources
- [Godot Documentation](https://docs.godotengine.org/)
- [VRM Specification](https://github.com/vrm-c/vrm-specification)
- [MediaPipe Solutions](https://developers.google.com/mediapipe/solutions)
- [V-Sekai godot-vrm](https://github.com/V-Sekai/godot-vrm)
- [GDMP Plugin](https://github.com/j20001970/GDMP)
- [VRigUnity Reference](https://github.com/Kariaro/VRigUnity)
