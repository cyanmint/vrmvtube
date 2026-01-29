# Git Submodules Migration

This document explains the conversion of godot-vrm and GDMP dependencies to git submodules.

## Changes Made

### Before
- `addons/vrm` - Managed via git-subrepo from V-Sekai/godot-vrm
- `third_party/GDMP` - Direct copy of GDMP repository
- `addons/GDMP` - Direct copy of GDMP addon files

### After
- `third_party/godot-vrm` - Git submodule pointing to https://github.com/V-Sekai/godot-vrm.git (branch: only-addon)
- `third_party/GDMP` - Git submodule pointing to https://github.com/j20001970/GDMP.git
- `addons/vrm` - Symbolic link to `third_party/godot-vrm`
- `addons/GDMP` - Symbolic link to `third_party/GDMP/addons/GDMP`

## Structure

```
vrmvtube/
├── .gitmodules                    # Git submodules configuration
├── addons/
│   ├── vrm -> ../third_party/godot-vrm  # Symlink
│   └── GDMP -> ../third_party/GDMP/addons/GDMP  # Symlink
└── third_party/
    ├── godot-vrm/                # Git submodule (V-Sekai/godot-vrm)
    │   ├── plugin.cfg
    │   ├── vrm_extension.gd
    │   └── ...
    └── GDMP/                     # Git submodule (j20001970/GDMP)
        ├── .gitmodules           # GDMP has its own submodules
        ├── godot-cpp/            # Nested submodule
        ├── mediapipe/            # Nested submodule
        └── addons/
            └── GDMP/
                ├── plugin.cfg
                └── ...
```

## Benefits

1. **Proper Version Control**: Git submodules provide built-in version tracking
2. **Easy Updates**: Update dependencies with `git submodule update --remote`
3. **Clear Separation**: Third-party code is clearly separated in `third_party/`
4. **Standard Workflow**: Uses standard git submodule commands
5. **Recursive Submodules**: GDMP's own submodules are properly initialized

## Working with Submodules

### Cloning the Repository

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/cyanmint/vrmvtube.git

# Or after cloning
git clone https://github.com/cyanmint/vrmvtube.git
cd vrmvtube
git submodule update --init --recursive
```

### Updating Submodules

```bash
# Update all submodules to latest commit on tracked branch
git submodule update --remote --recursive

# Update specific submodule
git submodule update --remote third_party/godot-vrm

# Commit the updates
git add third_party/
git commit -m "Update submodules"
```

### Checking Submodule Status

```bash
# Show current submodule commits
git submodule status

# Show detailed submodule info
git submodule foreach 'git log -1 --oneline'
```

## Submodule Details

### godot-vrm
- **Repository**: https://github.com/V-Sekai/godot-vrm.git
- **Branch**: only-addon
- **Purpose**: VRM model import and rendering support
- **License**: MIT

### GDMP
- **Repository**: https://github.com/j20001970/GDMP.git
- **Branch**: main (default)
- **Purpose**: MediaPipe integration for face tracking
- **License**: Apache-2.0
- **Nested Submodules**:
  - godot-cpp (Godot C++ bindings)
  - mediapipe (Google MediaPipe)

## CI/CD Integration

The GitHub Actions workflows automatically handle submodules:

```yaml
- name: Checkout
  uses: actions/checkout@v4
  with:
    submodules: recursive  # Automatically init and update submodules
```

## Compatibility

- Godot plugins work via symbolic links in the `addons/` directory
- The project structure remains compatible with Godot 4.3+
- No changes required to existing scripts or scenes
- Plugin paths remain as `res://addons/vrm/` and `res://addons/GDMP/`

## Troubleshooting

### Submodules not initialized
```bash
git submodule update --init --recursive
```

### Symlinks not working (Windows)
On Windows, you may need to:
1. Enable Developer Mode, OR
2. Run git with elevated privileges, OR
3. Use `git config core.symlinks true` before cloning

### Submodule detached HEAD
This is normal. Submodules point to specific commits, not branches.

## Migration Notes

- Previous git-subrepo commit: 651205484c35f5cd7ba56475ff636e10db8ad674
- Migration completed: 2026-01-29
- All addon functionality preserved
- No breaking changes to project structure
