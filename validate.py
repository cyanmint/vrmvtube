#!/usr/bin/env python3
"""
VRMVTube Code Validation Script

This script validates the GDScript code and scene files for common issues.
Run this before testing in Godot to catch potential problems early.
"""

import re
import os
from pathlib import Path

def check_file_exists(filepath):
    """Check if a file exists"""
    return os.path.exists(filepath)

def check_scene_references(scene_file):
    """Check if scene file references valid scripts"""
    with open(scene_file, 'r') as f:
        content = f.read()
    
    # Extract script paths
    script_refs = re.findall(r'path="(res://[^"]+\.gd)"', content)
    
    issues = []
    for script_ref in script_refs:
        # Convert res:// path to local path
        local_path = script_ref.replace('res://', '')
        if not check_file_exists(local_path):
            issues.append(f"Missing script: {script_ref} (local: {local_path})")
    
    return issues

def check_signal_connections(scene_file):
    """Extract and validate signal connections"""
    with open(scene_file, 'r') as f:
        content = f.read()
    
    # Find all signal connections
    connections = re.findall(
        r'\[connection signal="([^"]+)" from="([^"]+)" to="([^"]+)" method="([^"]+)"\]',
        content
    )
    
    print(f"\nSignal connections in {scene_file}:")
    for signal, from_node, to_node, method in connections:
        print(f"  {from_node}.{signal} -> {to_node}.{method}()")
    
    return connections

def check_node_references_in_script(script_file):
    """Check @onready var references in script"""
    if not check_file_exists(script_file):
        return []
    
    with open(script_file, 'r') as f:
        content = f.read()
    
    # Find all @onready references
    onready_refs = re.findall(r'@onready var \w+.*?=\s*\$([^\s]+)', content)
    
    if onready_refs:
        print(f"\nNode references in {script_file}:")
        for ref in onready_refs:
            print(f"  ${ref}")
    
    return onready_refs

def validate_project():
    """Run all validation checks"""
    print("=" * 60)
    print("VRMVTube Code Validation")
    print("=" * 60)
    
    # Check main scene
    main_scene = "scenes/main.tscn"
    print(f"\n✓ Checking {main_scene}...")
    
    if not check_file_exists(main_scene):
        print(f"✗ ERROR: {main_scene} not found!")
        return False
    
    scene_issues = check_scene_references(main_scene)
    if scene_issues:
        print("✗ Scene reference issues:")
        for issue in scene_issues:
            print(f"  - {issue}")
        return False
    else:
        print("✓ All script references valid")
    
    # Check signal connections
    connections = check_signal_connections(main_scene)
    if not connections:
        print("⚠ Warning: No signal connections found")
    
    # Check scripts
    scripts = [
        "scripts/main.gd",
        "scripts/webcam_tracker.gd",
        "scripts/face_rigging.gd",
        "scripts/camera_controller.gd"
    ]
    
    print("\n✓ Checking script files...")
    all_scripts_exist = True
    for script in scripts:
        if check_file_exists(script):
            print(f"  ✓ {script}")
            check_node_references_in_script(script)
        else:
            print(f"  ✗ {script} - NOT FOUND")
            all_scripts_exist = False
    
    if not all_scripts_exist:
        return False
    
    # Check example VRM model
    print("\n✓ Checking VRM model...")
    vrm_path = "example/cyanmint.vrm"
    if check_file_exists(vrm_path):
        size_mb = os.path.getsize(vrm_path) / (1024 * 1024)
        print(f"  ✓ {vrm_path} ({size_mb:.2f} MB)")
    else:
        print(f"  ⚠ Warning: {vrm_path} not found")
        print("    The app will work but won't auto-load a model")
    
    # Check project.godot
    print("\n✓ Checking project configuration...")
    if check_file_exists("project.godot"):
        with open("project.godot", 'r') as f:
            content = f.read()
        
        if 'run/main_scene="res://scenes/main.tscn"' in content:
            print("  ✓ Main scene configured correctly")
        else:
            print("  ⚠ Warning: Main scene may not be set")
        
        if 'addons/vrm/plugin.cfg' in content:
            print("  ✓ VRM plugin enabled")
        else:
            print("  ⚠ Warning: VRM plugin may not be enabled")
    else:
        print("  ✗ project.godot not found!")
        return False
    
    # Summary
    print("\n" + "=" * 60)
    print("Validation Summary")
    print("=" * 60)
    print("✓ All core files present")
    print("✓ Script references valid")
    print(f"✓ Found {len(connections)} signal connections")
    print("✓ Project structure looks good")
    print("\n📋 Next steps:")
    print("  1. Open the project in Godot 4.3+")
    print("  2. Enable the VRM plugin in Project Settings → Plugins")
    print("  3. Run the project (F5)")
    print("  4. See TESTING.md for detailed testing instructions")
    print("=" * 60)
    
    return True

if __name__ == "__main__":
    import sys
    success = validate_project()
    sys.exit(0 if success else 1)
