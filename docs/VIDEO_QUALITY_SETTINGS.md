# Video Quality Settings Documentation

## Overview

VRMVTube now includes comprehensive video quality and resolution controls, allowing users to optimize performance and visual quality for their specific hardware and use case.

## Available Settings

### 1. Resolution

Control the output resolution of the 3D viewport.

**Options:**
- **640x360 (nHD)** - Lowest resolution, best performance
- **854x480 (FWVGA)** - Mobile-friendly resolution
- **1280x720 (HD)** - Default, balanced quality and performance
- **1920x1080 (Full HD)** - High quality, recommended for streaming
- **2560x1440 (2K)** - Very high quality
- **3840x2160 (4K)** - Ultra high quality, requires powerful GPU

**Use Cases:**
- **Streaming**: Match your OBS capture resolution (usually 720p or 1080p)
- **Recording**: Higher resolutions for better video quality
- **Performance**: Lower resolutions if experiencing lag

### 2. Quality Presets

One-click presets that automatically configure multiple settings.

**Low:**
- MSAA: Disabled
- FXAA: Disabled  
- Render Scale: 0.75x
- **Best for:** Older hardware, integrated graphics, mobile devices

**Medium:**
- MSAA: Disabled
- FXAA: Enabled
- Render Scale: 1.0x
- **Best for:** Mid-range GPUs, balanced performance

**High (Default):**
- MSAA: 2x
- FXAA: Enabled
- Render Scale: 1.0x
- **Best for:** Modern GPUs, good balance of quality and performance

**Ultra:**
- MSAA: 4x
- FXAA: Enabled
- Render Scale: 1.0x
- **Best for:** High-end GPUs, prioritizing visual quality

### 3. Render Scale (DPI Scaling)

Adjusts the internal 3D rendering resolution independently from output resolution.

**Range:** 0.5x to 2.0x
**Default:** 1.0x (100% native resolution)

**Examples:**
- **0.5x** (50%) - Renders at half resolution, then upscales. Best performance boost.
- **0.75x** (75%) - Good balance for performance with minimal quality loss.
- **1.0x** (100%) - Native resolution, no scaling.
- **1.5x** (150%) - Super-sampling for better quality. Requires more GPU power.
- **2.0x** (200%) - Maximum quality super-sampling. Very demanding.

**Note:** Render scale affects 3D rendering performance directly. Lower = faster, higher = better quality but slower.

### 4. MSAA (Multi-Sample Anti-Aliasing)

Hardware-based anti-aliasing for smooth edges.

**Options:**
- **Disabled** - No MSAA, best performance
- **2x MSAA** - Minimal performance impact, moderate quality improvement
- **4x MSAA** - Moderate performance impact, good quality improvement
- **8x MSAA** - High performance impact, best quality improvement

**Trade-off:** Quality vs Performance
- More samples = smoother edges but lower FPS
- Works best with 3D models and geometry
- Can be combined with FXAA for best results

### 5. FXAA (Fast Approximate Anti-Aliasing)

Post-processing anti-aliasing for smooth visuals.

**Options:**
- **Disabled** - No FXAA
- **Enabled** - FXAA applied

**Characteristics:**
- Very low performance impact
- Works as a post-process effect
- Can slightly blur the image
- Good for general smoothing
- Recommended to combine with MSAA on High/Ultra presets

### 6. V-Sync (Vertical Synchronization)

Synchronizes frame rendering with monitor refresh rate.

**Options:**
- **Disabled** - No synchronization, may cause screen tearing
- **Enabled** - Syncs to monitor refresh, prevents tearing

**Effects:**
- **Enabled:** Smoother visuals, no tearing, caps FPS to monitor refresh rate
- **Disabled:** Potentially higher FPS, may have screen tearing

**Recommendation:** Keep enabled unless you need maximum FPS for recording.

### 7. Max FPS (Frames Per Second)

Caps the maximum frame rate.

**Range:** 30 to 240 FPS
**Default:** 60 FPS

**Common Settings:**
- **30 FPS** - Cinema-style, very smooth, lowest GPU usage
- **60 FPS** - Standard, recommended for most users
- **120 FPS** - High refresh rate monitors
- **144 FPS** - Gaming monitors
- **240 FPS** - Ultra high refresh monitors (if hardware supports)

**Note:** Actual FPS depends on hardware capability. Setting higher doesn't guarantee achieving it.

## Recommended Configurations

### For Streaming (OBS/Recording)

**720p Streaming:**
```
Resolution: 1280x720 (HD)
Quality: Medium or High
Render Scale: 1.0x
MSAA: Disabled or 2x
FXAA: Enabled
V-Sync: Disabled (OBS handles sync)
Max FPS: 60 FPS
```

**1080p Streaming:**
```
Resolution: 1920x1080 (Full HD)
Quality: High
Render Scale: 1.0x
MSAA: 2x
FXAA: Enabled
V-Sync: Disabled
Max FPS: 60 FPS
```

### For Low-End Hardware

**Maximum Performance:**
```
Resolution: 640x360 or 854x480
Quality: Low
Render Scale: 0.5x or 0.75x
MSAA: Disabled
FXAA: Disabled
V-Sync: Enabled (prevents wasted GPU cycles)
Max FPS: 30 FPS
```

### For High-End Hardware

**Maximum Quality:**
```
Resolution: 1920x1080 or 2560x1440
Quality: Ultra
Render Scale: 1.5x or 2.0x
MSAA: 4x or 8x
FXAA: Enabled
V-Sync: Enabled
Max FPS: 60 or 120 FPS
```

### For Content Creation

**High Quality Recording:**
```
Resolution: 1920x1080 (or higher)
Quality: Ultra
Render Scale: 1.5x (super-sampling)
MSAA: 4x
FXAA: Enabled
V-Sync: Disabled
Max FPS: 60 FPS
```

## Performance Impact

**From Most to Least Impactful:**

1. **Resolution** - Higher resolution = much more GPU work
2. **Render Scale** - Direct multiplier on rendering cost
3. **MSAA** - Significant GPU memory and processing impact
4. **Max FPS** - Higher = more work per second
5. **FXAA** - Minimal impact, post-process only
6. **V-Sync** - No performance impact, just sync behavior

## Technical Details

### How Settings are Applied

When you change video settings, VRMVTube applies them to the Godot viewport:

```gdscript
# Resolution
viewport.size = Vector2i(width, height)

# Render Scale (3D DPI)
viewport.scaling_3d_scale = scale_value

# MSAA
viewport.msaa_3d = Viewport.MSAA_2X  # (or 4X, 8X, DISABLED)

# FXAA
viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA

# V-Sync
DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

# Max FPS
Engine.max_fps = fps_value
```

### Settings Persistence

All video settings are saved to `user://settings.json`:

```json
{
    "video": {
        "resolution_width": 1280,
        "resolution_height": 720,
        "quality": "high",
        "render_scale": 1.0,
        "msaa": "disabled",
        "fxaa": false,
        "vsync": true,
        "max_fps": 60
    }
}
```

Settings are automatically saved when changed and loaded on application startup.

## Troubleshooting

### Low FPS / Stuttering

**Solutions:**
1. Lower resolution (try 720p instead of 1080p)
2. Reduce render scale to 0.75x or 0.5x
3. Disable MSAA
4. Use Low or Medium quality preset
5. Lower Max FPS to 30

### Blurry Image

**Solutions:**
1. Increase resolution
2. Increase render scale to 1.5x or 2.0x
3. Disable FXAA (it can blur slightly)
4. Use Higher MSAA (2x or 4x)

### Screen Tearing

**Solutions:**
1. Enable V-Sync
2. Match Max FPS to your monitor refresh rate

### Settings Not Saving

**Check:**
1. File permissions for `user://` directory
2. Disk space availability
3. Console for error messages about settings file

## Future Enhancements

Potential additions for future versions:

- Texture quality settings
- Shadow quality settings
- Ambient occlusion toggle
- Bloom/post-processing effects
- Custom resolution input
- Per-scene quality profiles
- Benchmark/auto-detect optimal settings

## API Reference

### Settings.gd

```gdscript
# Getters
get_video_resolution_width() -> int
get_video_resolution_height() -> int
get_video_quality() -> String
get_render_scale() -> float
get_msaa() -> String
get_fxaa() -> bool
get_vsync() -> bool
get_max_fps() -> int

# Setters
set_video_resolution(width: int, height: int)
set_video_quality(quality: String)  # "low", "medium", "high", "ultra"
set_render_scale(scale: float)       # 0.5 to 2.0
set_msaa(msaa: String)               # "disabled", "2x", "4x", "8x"
set_fxaa(enabled: bool)
set_vsync(enabled: bool)
set_max_fps(fps: int)                # 30 to 240
```

### ControlPanel.gd

```gdscript
# Signal
signal video_settings_changed()

# Getters
get_resolution() -> Vector2i
get_quality() -> String
get_render_scale() -> float
get_msaa() -> String
get_fxaa() -> bool
get_vsync() -> bool
get_max_fps() -> int
```

## See Also

- [Godot Viewport Documentation](https://docs.godotengine.org/en/stable/classes/class_viewport.html)
- [Godot Display Settings](https://docs.godotengine.org/en/stable/classes/class_displayserver.html)
- [Godot Engine Settings](https://docs.godotengine.org/en/stable/classes/class_engine.html)
