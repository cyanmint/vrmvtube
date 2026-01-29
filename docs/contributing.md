# Contributing to VRMVTube

Thank you for your interest in contributing to VRMVTube! This document provides guidelines for contributing to the project.

## How to Contribute

1. **Fork the Repository**
   - Fork the project on GitHub
   - Clone your fork locally

2. **Create a Branch**
   - Create a feature branch from `default`
   - Use a descriptive name: `feature/your-feature-name`

3. **Make Your Changes**
   - Follow the coding guidelines below
   - Test your changes thoroughly
   - Update documentation as needed

4. **Submit a Pull Request**
   - Push your changes to your fork
   - Create a pull request to the `default` branch
   - Describe your changes clearly

## Coding Guidelines

### GDScript Style

- Follow [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- Use type hints for all variables and functions
- Add comments for complex logic
- Keep functions small and focused

Example:
```gdscript
func calculate_distance(point_a: Vector3, point_b: Vector3) -> float:
	# Calculate Euclidean distance between two 3D points
	return point_a.distance_to(point_b)
```

### Testing

- Test on multiple platforms when possible
- Verify VRM model loading works
- Test MediaPipe tracking functionality
- Check UI responsiveness

### Documentation

- Update README.md for new features
- Add inline comments for complex code
- Update docs/ for major changes

## Code of Conduct

- Be respectful and inclusive
- Help others learn and grow
- Focus on constructive feedback
- Report issues responsibly

## License

By contributing, you agree that your contributions will be dedicated to the public domain under CC0 1.0 Universal, matching the project's license.

All third-party code must be properly attributed and licensed compatibly (MIT, Apache 2.0, etc.).

## Questions?

- Open an issue for bugs or feature requests
- Start a discussion for questions
- Check existing issues before creating new ones

## Development Setup

See [docs/building.md](building.md) for detailed setup instructions.

Thank you for contributing to VRMVTube! 🎉
