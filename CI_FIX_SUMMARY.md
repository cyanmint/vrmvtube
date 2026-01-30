# CI Build Failure Fix Summary

## Problem

The GitHub Actions workflow was failing during the GDMP checkout step with the following error:

```
/usr/bin/git -c protocol.version=2 fetch --no-tags --prune --no-recurse-submodules --depth=1 origin +refs/heads/main*:refs/remotes/origin/main*
The process '/usr/bin/git' failed with exit code 1
```

## Root Cause

The workflow configuration referenced the wrong branch for the GDMP repository:

- **Workflow setting:** `GDMP_REF: "main"`
- **Actual GDMP default branch:** `master`

The GDMP repository (j20001970/GDMP) uses `master` as its default branch, not `main`.

## Solution

Changed the `GDMP_REF` environment variable in `.github/workflows/build.yml`:

```diff
env:
  GODOT_VERSION: "4.6-stable"
  EXPORT_NAME: vrmvtube
  GDMP_REPO: "j20001970/GDMP"
- GDMP_REF: "main"
+ GDMP_REF: "master"
```

## Verification

1. ✅ Confirmed GDMP repository default branch via GitHub API
2. ✅ Validated workflow YAML syntax
3. ✅ Verified the change is minimal and correct

## Impact

This fix allows the CI workflow to:
- Successfully checkout the GDMP repository
- Build GDMP from source for all platforms (Linux, Windows, macOS, Android, Web)
- Use the built GDMP libraries in VRMVTube exports

## Affected Jobs

All GDMP build jobs will now work correctly:
- `build-gdmp-linux-x86_64`
- `build-gdmp-windows-x86_64`
- `build-gdmp-macos`
- `build-gdmp-android`
- `build-gdmp-web`

## Files Changed

- `.github/workflows/build.yml` (1 line changed)

## Commit

- **Commit:** `05c4cf6` - Fix CI build failure: Change GDMP branch from main to master
- **Branch:** `copilot/add-default-model-loading`
- **Status:** ✅ Pushed to origin

## Next Steps

1. Monitor the next CI workflow run
2. Verify GDMP checkout succeeds
3. Verify GDMP builds complete successfully
4. Verify VRMVTube exports use built GDMP libraries

---

**Date:** 2026-01-30
**Fixed by:** GitHub Copilot Agent
