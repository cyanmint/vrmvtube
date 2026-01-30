# CI Workflow Guide

## Overview

VRMVTube now has two GitHub Actions workflows for building and exporting the application:

1. **build.yml** - Simple, fast, reliable (DEFAULT)
2. **build-gdmp-from-source.yml** - Advanced, manual-only

## Workflow Comparison

| Feature | build.yml (Default) | build-gdmp-from-source.yml |
|---------|---------------------|----------------------------|
| **Trigger** | Automatic (push, PR) | Manual only |
| **GDMP Source** | Prebuilt libraries | Build from source |
| **Build Time** | 5-10 minutes | 30-60 minutes |
| **Resource Usage** | Low | Very High |
| **Reliability** | High | Medium |
| **Use Case** | Normal development | GDMP library updates |

## Default Workflow: build.yml

### What It Does

1. **Downloads MediaPipe Models** (cached)
   - Hand landmarker (~7.5 MB)
   - Face landmarker (~3.6 MB)

2. **Exports VRMVTube** (parallel)
   - Windows Desktop (.exe)
   - Linux x86_64 (.x86_64)
   - Web (HTML5/WASM)

### Features

- **Fast**: 5-10 minute total build time
- **Reliable**: Uses stable prebuilt GDMP libraries
- **Efficient**: Parallel exports, cached models
- **Robust**: Timeout protection, error tolerance
- **Always uploads**: Artifacts uploaded even on partial success

### When It Runs

**Automatically:**
- Push to `default`, `develop`, or `copilot/**` branches
- Pull requests to `default` or `develop` branches

**Manually:**
- Via GitHub Actions UI (workflow_dispatch)

### Artifacts

All artifacts are retained for 14 days:

- `mediapipe-models` - MediaPipe model files (7 days)
- `vrmvtube-windows` - Windows build
- `vrmvtube-linux` - Linux build
- `vrmvtube-web` - Web build

## Advanced Workflow: build-gdmp-from-source.yml

### What It Does

**Stage 1: Build GDMP** (6 parallel jobs)
1. Download MediaPipe models
2. Build GDMP for Linux x86_64
3. Build GDMP for Windows x86_64
4. Build GDMP for macOS (universal)
5. Build GDMP for Android arm64
6. Build GDMP for Web (WASM)
7. Collect all libraries

**Stage 2: Export VRMVTube** (3 parallel jobs)
- Uses freshly-built GDMP libraries
- Exports Windows, Linux, Web

### When to Use

**Use this workflow when:**
- Updating GDMP to a newer version
- Testing custom GDMP modifications
- Rebuilding all platform libraries
- Creating a complete GDMP distribution

**Don't use for:**
- Normal development
- Testing application changes
- Quick iterations
- PR checks

### How to Run

1. Go to GitHub Actions tab
2. Select "Build GDMP from Source (Advanced)"
3. Click "Run workflow"
4. Select branch
5. Click "Run workflow" button
6. Wait 30-60 minutes

### Resource Requirements

- **Time**: 30-60 minutes total
- **Memory**: Up to 7GB per platform
- **Disk**: Up to 10GB per platform
- **Network**: ~2GB downloads

### Platform Builds

| Platform | Time | Output | Size |
|----------|------|--------|------|
| Linux x86_64 | 15-20 min | libGDMP.linux.so | ~35 MB |
| Windows x86_64 | 18-22 min | GDMP.windows.dll | ~13 MB |
| macOS | 15-20 min | libGDMP.macos.dylib | ~30 MB |
| Android arm64 | 18-22 min | libGDMP.android.so | ~24 MB |
| Web | 20-25 min | GDMP.web.wasm | ~38 MB |

## Troubleshooting

### Build Fails on Import

**Symptom:** Import step times out or fails
**Cause:** Godot can't load project properly
**Solution:**
- Check project.godot is valid
- Verify all addons are present
- Check for missing dependencies

### Export Produces No Files

**Symptom:** Export step succeeds but no files in artifact
**Cause:** Export preset not found or misconfigured
**Solution:**
- Verify export_presets.cfg exists
- Check preset names match workflow
- Test export locally first

### GDMP Library Errors

**Symptom:** "Cannot load GDMP extension"
**Cause:** Library missing or wrong architecture
**Solution:**
- Verify library exists in `addons/GDMP/libs/`
- Check file permissions (Linux/macOS)
- Use correct architecture for export

### MediaPipe Models Missing

**Symptom:** Tracking doesn't work
**Cause:** Model files not downloaded
**Solution:**
- Check download-models job succeeded
- Verify artifact was uploaded
- Models should be in `assets/models/mediapipe/`

### Out of Memory

**Symptom:** Build killed or fails with OOM
**Cause:** Insufficient memory (GDMP build only)
**Solution:**
- Use default workflow (prebuilt libraries)
- Don't run GDMP build unless necessary
- Consider building GDMP locally instead

## Best Practices

### For Normal Development

1. Use **build.yml** (default workflow)
2. Let it run automatically on push
3. Download artifacts from successful runs
4. Test builds before merging

### For GDMP Updates

1. Update GDMP submodule/files locally
2. Test build locally first
3. Manually trigger **build-gdmp-from-source.yml**
4. Wait for completion (~30-60 minutes)
5. Download and test all platform libraries
6. Commit updated libraries to repository

### For Releases

1. Ensure all tests pass
2. Run both workflows
3. Verify all exports work
4. Download all artifacts
5. Test on actual hardware
6. Create GitHub release
7. Upload tested builds

## Workflow Modifications

### Adding New Export Platform

Edit `build.yml`:

```yaml
export-android:
  name: Export Android
  runs-on: ubuntu-latest
  needs: [download-models]
  steps:
    - name: Checkout
      uses: actions/checkout@v4
    # ... similar to other export jobs
```

### Changing Godot Version

Update `env.GODOT_VERSION` in workflow:

```yaml
env:
  GODOT_VERSION: "4.6-stable"  # Change here
```

### Adding Build Platforms to GDMP Build

Edit `build-gdmp-from-source.yml`:

1. Add new build job
2. Add to `collect-gdmp` needs
3. Update collection script
4. Test thoroughly

## Monitoring

### Check Build Status

1. Go to repository on GitHub
2. Click "Actions" tab
3. Select workflow run
4. View job logs

### Download Artifacts

1. Go to completed workflow run
2. Scroll to "Artifacts" section
3. Click artifact name to download
4. Extract and test

### View Logs

1. Click on specific job
2. Expand steps to see output
3. Look for errors in red text
4. Check timing information

## FAQ

**Q: Why not always build GDMP from source?**
A: It's extremely resource-intensive, time-consuming, and unnecessary for most development work. Prebuilt libraries work fine.

**Q: How often should I rebuild GDMP?**
A: Only when updating GDMP version or modifying GDMP source code. For most developers: never.

**Q: Can I disable the GDMP build workflow?**
A: It's already manual-only, so it won't run unless you explicitly trigger it.

**Q: Why are builds so slow?**
A: GDMP builds from source involve compiling MediaPipe and Godot bindings, which is complex and time-consuming.

**Q: What if the simple workflow fails?**
A: Check the logs for specific errors. Common issues are export preset configuration or missing files.

**Q: Can I run both workflows simultaneously?**
A: Yes, but it's wasteful. The simple workflow is sufficient for normal development.

## Getting Help

If builds continue to fail:

1. Check workflow logs for specific errors
2. Review this guide's troubleshooting section
3. Test export locally on your machine
4. Create an issue with full error logs
5. Include workflow run link

## Summary

- **Use build.yml for normal development** - Fast, reliable, automatic
- **Use build-gdmp-from-source.yml rarely** - Only for GDMP updates
- **Monitor workflow runs** - Check Actions tab regularly
- **Download artifacts** - Test builds before merging
- **Keep it simple** - Don't over-complicate the build process

The default workflow is designed to "just work" for 99% of development needs!
