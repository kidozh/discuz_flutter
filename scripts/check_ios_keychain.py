#!/usr/bin/env python3
"""Reject iOS installation artifacts that cannot access their own Keychain."""
import argparse
import platform
import plistlib
import re
import subprocess
from pathlib import Path
from xml.parsers.expat import ExpatError


def simulator_entitlements(output):
    # otool prints each little-endian 32-bit word in host order. Both supported
    # iOS Simulator architectures (arm64 and x86_64) are little-endian.
    data = bytearray()
    for line in output.splitlines():
        if re.fullmatch(r'[0-9a-fA-F]+\s+(?:(?:[0-9a-fA-F]{2}){1,4}\s*)+', line):
            for word in line.split()[1:]:
                data.extend(int(word, 16).to_bytes(len(word) // 2, 'little'))
    return plistlib.loads(bytes(data).rstrip(b'\0'))


def validate_entitlements(bundle_id, entitlements):
    errors = []
    application_id = entitlements.get('application-identifier', '')
    if not application_id or not application_id.endswith('.' + bundle_id):
        errors.append('The signature must contain this app\'s application-identifier.')
    groups = entitlements.get('keychain-access-groups', [])
    # Keep the existing default access group. A differently named group can
    # strand passwords saved by earlier signed versions.
    if not application_id or application_id not in groups:
        errors.append('The signature must retain the app\'s own default Keychain access group.')
    return errors


def check_app(app):
    with (app / 'Info.plist').open('rb') as source:
        info = plistlib.load(source)
    result = subprocess.run(
        ['codesign', '--display', '--entitlements', '-', '--der', str(app)],
        capture_output=True, check=False,
    )
    if result.returncode:
        return ['The app must be signed before installation or upload.']
    try:
        if info.get('DTPlatformName') == 'iphonesimulator':
            # Xcode embeds simulated entitlements in Mach-O, rather than the
            # code signature. Disabling signing omits this section entirely.
            result = subprocess.run(
                ['xcrun', 'otool', '-arch', platform.machine(), '-X', '-s',
                 '__TEXT', '__entitlements', str(app / info['CFBundleExecutable'])],
                capture_output=True, check=True,
            )
            entitlements = simulator_entitlements(result.stdout.decode())
        else:
            # Current Apple signatures use DER. The optional legacy XML blob
            # may be omitted even when the DER entitlements are valid.
            decoded = subprocess.run(
                ['derq', 'query', '-i', '-', '--xml'],
                input=result.stdout, capture_output=True, check=True,
            )
            entitlements = plistlib.loads(decoded.stdout)
    except (ValueError, plistlib.InvalidFileException, ExpatError):
        return ['The app signature has no readable entitlements. Do not install an unsigned build.']
    return validate_entitlements(info['CFBundleIdentifier'], entitlements)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--app', type=Path, required=True)
    args = parser.parse_args()
    try:
        errors = check_app(args.app)
    except (OSError, KeyError, ValueError, subprocess.CalledProcessError) as error:
        errors = [str(error)]
    for error in errors:
        print('ERROR: ' + error)
    if not errors:
        print('iOS signing and default Keychain access group checks passed.')
    return bool(errors)


if __name__ == '__main__':
    raise SystemExit(main())
