#!/usr/bin/env python3
"""Validate Duo build requirements; never mistake deployment target for SDK."""
import argparse
import plistlib
import re
import subprocess
from pathlib import Path

MIN_SDK = (27, 1)


def sdk_version(value):
    match = re.search(r"(\d+)\.(\d+)", value)
    if not match:
        raise ValueError(f"Cannot parse iOS SDK version: {value!r}")
    return tuple(map(int, match.groups()))


def check(root, sdk, app=None):
    errors = []
    with (root / "ios/Runner/Info.plist").open("rb") as source:
        info = plistlib.load(source)
    required = {"UIInterfaceOrientationPortrait", "UIInterfaceOrientationLandscapeLeft",
                "UIInterfaceOrientationLandscapeRight"}
    if not required.issubset(info.get("UISupportedInterfaceOrientations", [])):
        errors.append("Outer display must support portrait and both landscape orientations.")
    if info.get("UIRequiresFullScreen", False):
        errors.append("UIRequiresFullScreen prevents resizable window support.")
    if not info.get("UIApplicationSceneManifest", {}).get("UISceneConfigurations"):
        errors.append("A UIKit scene configuration is required.")
    project = (root / "ios/Runner.xcodeproj/project.pbxproj").read_text()
    families = re.findall(r'TARGETED_DEVICE_FAMILY\s*=\s*"([^"]+)"', project)
    if not families or any(set(f.replace(" ", "").split(",")) != {"1", "2"} for f in families):
        errors.append("All Runner configurations must support iPhone and iPad.")
    actual_sdk = sdk_version(sdk)
    if app:
        with (app / "Info.plist").open("rb") as source:
            built_info = plistlib.load(source)
        actual_sdk = sdk_version(built_info.get("DTSDKName", ""))
    return errors, actual_sdk


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--require-duo", action="store_true",
                        help="Fail when the selected/built SDK is older than iOS 27.1")
    parser.add_argument("--sdk-version", help="SDK override for reproducible checks")
    parser.add_argument("--app", type=Path, help="Inspect the SDK recorded in a built .app")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    try:
        sdk = args.sdk_version or subprocess.check_output(
            ["xcrun", "--sdk", "iphoneos", "--show-sdk-version"], text=True).strip()
        errors, actual_sdk = check(root, sdk, args.app)
        print(f"iOS SDK: {actual_sdk[0]}.{actual_sdk[1]}")
        if actual_sdk < MIN_SDK:
            message = "iPhone Duo full-display support requires iOS 27.1 SDK / Xcode 27.1 or newer."
            if args.require_duo:
                errors.append(message)
            else:
                print(f"WARNING: {message} This build uses compatibility scaling.")
        for error in errors:
            print(f"ERROR: {error}")
        if not errors:
            print("Duo project configuration checks passed.")
        return 1 if errors else 0
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"ERROR: {error}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
