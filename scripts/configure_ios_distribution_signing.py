#!/usr/bin/env python3
"""Configure both embedded apps with the profiles downloaded by CI."""
import argparse
import json
from pathlib import Path
import plistlib
import re
import subprocess
import uuid


def select_profile(raw):
    profiles = json.loads(raw)
    for profile in profiles:
        if profile.get('type') == 'IOS_APP_STORE':
            uuid.UUID(profile['udid'])
            return profile['udid']
    raise ValueError('No active App Store profile was downloaded for the app.')


def patch_configuration(source, configuration_id, profile):
    pattern = re.compile(
        r'(^\s*' + re.escape(configuration_id)
        + r' /\* Release \*/ = \{\n)(.*?)(^\t\t\};)',
        re.MULTILINE | re.DOTALL,
    )
    changes = {
        # Automatic archives use development signing; App Store export then
        # re-signs both apps with the distribution certificate.
        'CODE_SIGN_IDENTITY': 'Apple Development',
        # Xcode-managed Team Store profiles require automatic signing. Pinning
        # their UUID with Manual fails even when the certificate is installed.
        'CODE_SIGN_STYLE': 'Automatic',
        'PROVISIONING_PROFILE_SPECIFIER': '',
    }

    def replace(match):
        block = match.group(2)
        for key, value in changes.items():
            setting = key + ' = ' + json.dumps(value) + ';'
            existing = re.compile(r'^([ \t]*)' + key + r' = [^\n]*;$', re.MULTILINE)
            if existing.search(block):
                block = existing.sub(lambda found: found.group(1) + setting, block)
            else:
                block = block.replace('buildSettings = {\n', 'buildSettings = {\n\t\t\t\t' + setting + '\n', 1)
        return match.group(1) + block + match.group(3)

    updated, count = pattern.subn(replace, source)
    if count != 1:
        raise ValueError('Cannot locate the Release configuration ' + configuration_id)
    return updated


def configure_project(source, project, profiles):
    objects = project['objects']
    found = set()
    for target in objects.values():
        if target.get('isa') != 'PBXNativeTarget':
            continue
        configurations = objects[target['buildConfigurationList']]['buildConfigurations']
        for identifier in configurations:
            configuration = objects[identifier]
            bundle = configuration.get('buildSettings', {}).get('PRODUCT_BUNDLE_IDENTIFIER')
            if configuration.get('name') == 'Release' and bundle in profiles:
                source = patch_configuration(source, identifier, profiles[bundle])
                found.add(bundle)
    if found != set(profiles):
        raise ValueError('Missing Release targets for: ' + ', '.join(set(profiles) - found))
    return source


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--iphone-profiles', required=True)
    parser.add_argument('--watch-profiles', required=True)
    parser.add_argument('--project', type=Path, default=Path('ios/Runner.xcodeproj/project.pbxproj'))
    parser.add_argument('--template', type=Path, default=Path('ios/ExportOptions.plist'))
    parser.add_argument('--export-options', type=Path, required=True)
    args = parser.parse_args()
    profiles = {
        'com.kidozh.discuz-flutter': select_profile(args.iphone_profiles),
        'com.kidozh.discuz-flutter.watchkitapp': select_profile(args.watch_profiles),
    }
    project = json.loads(subprocess.check_output([
        'plutil', '-convert', 'json', '-o', '-', str(args.project),
    ]))
    source = configure_project(args.project.read_text(), project, profiles)
    with args.template.open('rb') as file:
        options = plistlib.load(file)
    options.pop('provisioningProfiles', None)
    options['signingStyle'] = 'automatic'
    args.export_options.parent.mkdir(parents=True, exist_ok=True)
    with args.export_options.open('wb') as file:
        plistlib.dump(options, file)
    args.project.write_text(source)
    print('Configured App Store distribution profiles for iPhone and Apple Watch.')


if __name__ == '__main__':
    main()
