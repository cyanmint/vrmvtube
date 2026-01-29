#!/usr/bin/env python3
"""
Build validation script for VRMVTube
Checks for common issues before building
"""

import os
import sys
import re
from pathlib import Path

def check_file_exists(path, description):
    """Check if a file exists"""
    if not os.path.exists(path):
        print(f"✗ Missing: {description} ({path})")
        return False
    print(f"✓ Found: {description}")
    return True

def check_export_preset():
    """Validate export preset configuration"""
    print("\n=== Checking export_presets.cfg ===")
    preset_path = "export_presets.cfg"
    
    if not check_file_exists(preset_path, "Export presets"):
        return False
    
    with open(preset_path, 'r') as f:
        content = f.read()
    
    # Check for Android preset
    if 'name="Android"' not in content:
        print("✗ Android export preset not found")
        return False
    print("✓ Android export preset exists")
    
    # Check gradle is disabled
    if 'gradle_build/use_gradle_build=true' in content:
        print("✗ Gradle build is enabled (should be false for CI)")
        return False
    print("✓ Gradle build is disabled")
    
    # Check for required presets
    presets = ['Windows', 'Linux', 'macOS', 'Android', 'Web']
    for preset in presets:
        if f'name="{preset}"' in content:
            print(f"✓ {preset} preset exists")
        else:
            print(f"⚠ {preset} preset not found")
    
    return True

def check_workflow():
    """Validate GitHub workflow"""
    print("\n=== Checking .github/workflows/build.yml ===")
    workflow_path = ".github/workflows/build.yml"
    
    if not check_file_exists(workflow_path, "Build workflow"):
        return False
    
    with open(workflow_path, 'r') as f:
        content = f.read()
    
    # Check no gradle references
    gradle_refs = re.findall(r'gradle', content, re.IGNORECASE)
    if gradle_refs:
        print(f"⚠ Found {len(gradle_refs)} gradle reference(s) - may be in comments")
    else:
        print("✓ No gradle references found")
    
    # Check for required jobs
    jobs = ['export-windows', 'export-linux', 'export-macos', 'export-web', 'export-android']
    for job in jobs:
        if job in content:
            print(f"✓ Job '{job}' exists")
        else:
            print(f"✗ Job '{job}' not found")
            return False
    
    return True

def check_scripts():
    """Validate GDScript files"""
    print("\n=== Checking GDScript files ===")
    script_dir = Path("scripts")
    
    if not script_dir.exists():
        print("✗ scripts directory not found")
        return False
    
    scripts = list(script_dir.glob("*.gd"))
    if not scripts:
        print("✗ No .gd files found in scripts/")
        return False
    
    print(f"✓ Found {len(scripts)} GDScript file(s)")
    
    for script in scripts:
        # Check file is not empty
        if script.stat().st_size == 0:
            print(f"✗ Empty file: {script.name}")
            return False
        
        # Check extends statement
        with open(script, 'r') as f:
            first_line = f.readline().strip()
            if not first_line.startswith('extends'):
                print(f"⚠ {script.name}: First line doesn't start with 'extends'")
            else:
                print(f"✓ {script.name}: Valid structure")
    
    return True

def check_project():
    """Validate project.godot"""
    print("\n=== Checking project.godot ===")
    project_path = "project.godot"
    
    if not check_file_exists(project_path, "Project configuration"):
        return False
    
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Check config version
    if 'config_version=5' in content:
        print("✓ Godot 4.x project detected")
    else:
        print("⚠ Unknown Godot version")
    
    # Check window size (portrait mode)
    if 'viewport_width=720' in content and 'viewport_height=1280' in content:
        print("✓ Portrait mode configured (720x1280)")
    else:
        print("⚠ Portrait mode may not be configured correctly")
    
    # Check plugins
    if 'res://addons/vrm/plugin.cfg' in content:
        print("✓ VRM plugin referenced")
    else:
        print("⚠ VRM plugin not enabled")
    
    if 'res://addons/Godot-MToon-Shader/plugin.cfg' in content:
        print("✓ MToon Shader plugin referenced")
    else:
        print("⚠ MToon Shader plugin not enabled")
    
    return True

def check_addons():
    """Validate addon structure"""
    print("\n=== Checking addons ===")
    addons_dir = Path("addons")
    
    if not addons_dir.exists():
        print("✗ addons directory not found")
        return False
    
    # Check VRM addon
    vrm_plugin = addons_dir / "vrm" / "plugin.cfg"
    if vrm_plugin.exists():
        print("✓ VRM addon found")
    else:
        print("✗ VRM addon plugin.cfg not found")
        return False
    
    # Check MToon addon
    mtoon_plugin = addons_dir / "Godot-MToon-Shader" / "plugin.cfg"
    if mtoon_plugin.exists():
        print("✓ MToon Shader addon found")
    else:
        print("✗ MToon Shader addon plugin.cfg not found")
        return False
    
    return True

def main():
    """Run all validation checks"""
    print("VRMVTube Build Validation")
    print("=" * 50)
    
    # Change to repo root
    repo_root = Path(__file__).parent
    os.chdir(repo_root)
    
    checks = [
        ("Export Preset", check_export_preset),
        ("GitHub Workflow", check_workflow),
        ("GDScript Files", check_scripts),
        ("Project Configuration", check_project),
        ("Addons", check_addons),
    ]
    
    results = []
    for name, check_func in checks:
        try:
            result = check_func()
            results.append((name, result))
        except Exception as e:
            print(f"\n✗ Error checking {name}: {e}")
            results.append((name, False))
    
    # Summary
    print("\n" + "=" * 50)
    print("VALIDATION SUMMARY")
    print("=" * 50)
    
    all_passed = True
    for name, result in results:
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"{status}: {name}")
        if not result:
            all_passed = False
    
    print("=" * 50)
    if all_passed:
        print("✓ All checks passed!")
        print("\nThe project is ready to build.")
        return 0
    else:
        print("✗ Some checks failed!")
        print("\nPlease fix the issues above before building.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
