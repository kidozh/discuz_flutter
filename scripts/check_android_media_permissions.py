#!/usr/bin/env python3
"""Fail CI if a packaged Android manifest grants broad media access."""
import argparse
import xml.etree.ElementTree as ET


ANDROID = '{http://schemas.android.com/apk/res/android}'
BLOCKED_PERMISSIONS = {
    'READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE', 'READ_MEDIA_IMAGES',
    'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO', 'READ_MEDIA_VISUAL_USER_SELECTED',
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('manifest')
    args = parser.parse_args()
    manifest = ET.parse(args.manifest).getroot()
    permissions = {
        element.get(ANDROID + 'name') for element in manifest
        if element.tag.startswith('uses-permission')
    }
    blocked = permissions & {f'android.permission.{name}' for name in BLOCKED_PERMISSIONS}
    if blocked:
        parser.error('Packaged manifest still declares ' + ', '.join(sorted(blocked)))
    print(f'Media permissions verified in {args.manifest}')


if __name__ == '__main__':
    main()
