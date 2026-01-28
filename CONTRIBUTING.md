# Contributing to VRMVTube

Thank you for your interest in contributing to VRMVTube!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone --recursive https://github.com/YOUR_USERNAME/vrmvtube.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes
6. Commit your changes: `git commit -m "Add your feature"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Setup

### Prerequisites

- Godot 4.3 or newer
- Git with submodule support
- (Optional) A VRM model for testing

### Setting Up

1. Clone the repository with submodules:
   ```bash
   git clone --recursive https://github.com/cyanmint/vrmvtube.git
   cd vrmvtube
   ```

2. Open the project in Godot 4.3+

3. Enable plugins in Project Settings → Plugins:
   - MToon
   - vrm

4. Run the project to test

## Code Style

Please follow the guidelines in `.github/copilot-instructions.md`:

- Use 4 spaces for indentation
- Use snake_case for variables and functions
- Use PascalCase for class names
- Add type hints to all variables and function parameters
- Add docstrings to complex functions

## Testing

Before submitting a PR:

1. Test your changes in the Godot editor
2. Export for at least one platform to verify it builds
3. Check for console errors
4. Verify VRM models still load correctly

## License Compliance

**Important**: This project uses CC0 1.0 Universal, but depends on libraries with their own licenses:

- godot-vrm: MIT License (V-Sekai)
- MToon Shader: MIT License
- Godot Engine: MIT License

When contributing:

1. Ensure any new dependencies are compatible with CC0
2. Add proper attribution for any copied code
3. Document new dependencies in README.md
4. Never remove or modify license notices in dependencies

## Adding Dependencies

Before adding a new dependency:

1. Check its license is compatible (MIT, Apache 2.0, BSD, etc.)
2. Add it as a git submodule if possible
3. Update README.md with attribution
4. Update `.github/copilot-instructions.md` with usage guidelines

## Pull Request Guidelines

### Title

Use conventional commit format:
```
type(scope): description

Examples:
feat(vrm): add support for VRM 1.0 animations
fix(camera): resolve zoom bounds issue
docs(readme): update installation instructions
```

### Description

Include:
- What changes were made
- Why the changes were necessary
- Any breaking changes
- Screenshots (if UI changes)
- Testing performed

### Checklist

- [ ] Code follows project style guidelines
- [ ] All dependencies are properly credited
- [ ] Changes have been tested locally
- [ ] README.md is updated if needed
- [ ] No hardcoded paths or secrets
- [ ] Platform compatibility is maintained
- [ ] License compliance is maintained

## Feature Requests

Have an idea? Open an issue with:
- Clear description of the feature
- Use cases
- Why it would be valuable
- (Optional) Implementation suggestions

## Bug Reports

Found a bug? Open an issue with:
- Description of the bug
- Steps to reproduce
- Expected behavior
- Actual behavior
- Platform and Godot version
- Screenshots or logs if applicable

## Platform-Specific Contributions

When adding platform-specific features:

- Document platform limitations clearly
- Use Godot's platform detection: `OS.get_name()`
- Provide graceful fallbacks for unsupported platforms
- Update README.md platform support table

### Virtual Camera

Virtual camera support is only available on Windows and Linux. When working on this:

- Always check platform before enabling features
- Provide clear error messages on unsupported platforms
- Document the limitation in code comments

## Questions?

- Check existing issues and discussions
- Read the documentation in README.md
- Review `.github/copilot-instructions.md`
- Open a new issue if needed

## Code of Conduct

Be respectful, constructive, and professional in all interactions.

## Attribution

By contributing, you agree that:
- Your contributions will be licensed under CC0 1.0 Universal
- You have the right to contribute the code
- You understand the AI-generated nature of this project

## Thank You!

Every contribution, no matter how small, is appreciated!
