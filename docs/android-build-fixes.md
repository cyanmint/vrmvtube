# Android Build Fixes Documentation

## Overview
This document explains the Android build issues encountered and how they were resolved.

## Problems Identified

### 1. Missing Build Output Directories
**Error**: `Export: Target folder does not exist or is inaccessible: "builds/android"`

**Cause**: Godot export requires the output directory to exist before exporting.

**Solution**: CI workflow creates the directory with `mkdir -p build/android` before export.

### 2. Missing Android Build Template Version File
**Error**: `Trying to build from a gradle built template, but no version info for it exists.`

**Cause**: Godot's Android export platform checks for a `.build_version` file in `android/build/` to validate that the gradle build template matches the current Godot version.

**Solution**: 
- Added `android/build/.build_version` file to repository
- Content: `4.6.stable` (matches the `GODOT_TEMPLATES_VERSION` variable in CI)
- This file is committed to git and available in all builds

### 3. Missing AAR Library Files
**Error**: Same as #2 - Godot also checks if the AAR files exist in `android/build/libs/`

**Cause**: The Android build template requires two large AAR files:
- `libs/debug/godot-lib.template_debug.aar` (105 MB)
- `libs/release/godot-lib.template_release.aar` (96 MB)

These files cannot be committed to GitHub without Git LFS due to size constraints.

**Solution**:
- Added CI workflow step to extract AAR files from `android_source.zip`
- The `android_source.zip` is included in the Godot export templates
- Extraction happens during CI build before Android export

### 4. Version Format Mismatch
**Error**: Version validation failure

**Cause**: Initial `.build_version` file contained `4.6.0.stable` but CI uses `4.6.stable`

**Solution**: Updated `.build_version` to contain exactly `4.6.stable` to match:
- `GODOT_TEMPLATES_VERSION` environment variable: `4.6.stable`
- Export templates directory: `~/.local/share/godot/export_templates/4.6.stable/`

## Android Build Template Structure

```
android/build/
├── .build_version              # Version marker (committed to git)
├── assetPackInstallTime/       # Asset pack configuration
├── build.gradle                # Main Gradle build script (committed)
├── config.gradle               # Gradle configuration (committed)
├── gradle/                     # Gradle wrapper (committed)
│   └── wrapper/
├── gradle.properties           # Gradle properties (committed)
├── gradlew                     # Gradle wrapper script (committed)
├── gradlew.bat                # Gradle wrapper for Windows (committed)
├── libs/                       # AAR libraries (extracted in CI, not committed)
│   ├── debug/
│   │   └── godot-lib.template_debug.aar   # 105 MB
│   └── release/
│       └── godot-lib.template_release.aar # 96 MB
├── res/                        # Android resources (committed)
├── settings.gradle             # Gradle settings (committed)
└── src/                        # Source templates (committed)
    ├── main/
    ├── debug/
    ├── release/
    └── instrumented/
```

## CI Workflow for Android Export

The complete Android export job in `.github/workflows/build.yml`:

```yaml
export-android:
  name: Android Export
  runs-on: ubuntu-latest
  steps:
    - name: Checkout
      uses: actions/checkout@v4
      with:
        lfs: true
    
    - name: Setup Android SDK
      uses: android-actions/setup-android@v3
    
    - name: Setup Java
      uses: actions/setup-java@v4
      with:
        distribution: 'temurin'
        java-version: '17'
    
    - name: Download Godot
      run: |
        wget -q https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip
        unzip -q Godot_v${GODOT_VERSION}_linux.x86_64.zip
        chmod +x Godot_v${GODOT_VERSION}_linux.x86_64
        mkdir -p $HOME/.local/bin
        mv Godot_v${GODOT_VERSION}_linux.x86_64 $HOME/.local/bin/godot
        echo "$HOME/.local/bin" >> $GITHUB_PATH
    
    - name: Download Export Templates
      run: |
        wget -q https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_export_templates.tpz
        mkdir -p $HOME/.local/share/godot/export_templates
        unzip -q Godot_v${GODOT_VERSION}_export_templates.tpz
        mv templates $HOME/.local/share/godot/export_templates/${GODOT_TEMPLATES_VERSION}
    
    - name: Setup Android Build Template AAR Files
      run: |
        # Extract android_source.zip to a temp location
        mkdir -p /tmp/android_source
        cd /tmp/android_source
        unzip -q $HOME/.local/share/godot/export_templates/${GODOT_TEMPLATES_VERSION}/android_source.zip
        # Copy the AAR libs to the project's android/build directory
        mkdir -p $GITHUB_WORKSPACE/android/build/libs
        cp -r libs/* $GITHUB_WORKSPACE/android/build/libs/
    
    - name: Android Build
      run: |
        mkdir -v -p build/android
        godot --headless --verbose --export-debug "Android" ./build/android/$EXPORT_NAME.apk
        
    - name: Upload Artifact
      uses: actions/upload-artifact@v4
      with:
        name: android
        path: build/android
```

## Key Points

1. **Version Matching is Critical**: The `.build_version` file must exactly match the `GODOT_TEMPLATES_VERSION` used in CI.

2. **AAR Files Are Required**: Godot's Android export checks for the existence and validity of AAR files in `android/build/libs/`.

3. **Not Committed to Git**: The large AAR files are extracted during CI builds, not stored in the repository.

4. **Template Structure**: The Android build template structure from `android_source.zip` must be preserved.

## Testing Locally

To test Android export locally:

```bash
# 1. Download Godot 4.6 stable
wget https://github.com/godotengine/godot/releases/download/4.6-stable/Godot_v4.6-stable_linux.x86_64.zip
unzip Godot_v4.6-stable_linux.x86_64.zip

# 2. Download export templates
wget https://github.com/godotengine/godot/releases/download/4.6-stable/Godot_v4.6-stable_export_templates.tpz
mkdir -p ~/.local/share/godot/export_templates
unzip Godot_v4.6-stable_export_templates.tpz
mv templates ~/.local/share/godot/export_templates/4.6.stable

# 3. Extract AAR files
cd android/build
unzip -q ~/.local/share/godot/export_templates/4.6.stable/android_source.zip
# The libs/ directory will now contain the AAR files

# 4. Export
mkdir -p builds/android
./Godot_v4.6-stable_linux.x86_64 --headless --export-debug "Android" builds/android/vrmvtube.apk
```

## Troubleshooting

### Error: "no version info for it exists"
- Check that `android/build/.build_version` exists and contains `4.6.stable`
- Check that AAR files exist in `android/build/libs/debug/` and `android/build/libs/release/`

### Error: "Target folder does not exist"
- Ensure the output directory is created before export: `mkdir -p builds/android`

### Error: Related to Gradle or AAR files
- Re-extract `android_source.zip` to ensure all files are present
- Check that `.build_version` matches your Godot version

## References

- Godot Android Export Documentation: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
- Godot Export Templates: https://godotengine.org/download/
- Android Gradle Plugin: https://developer.android.com/studio/releases/gradle-plugin
