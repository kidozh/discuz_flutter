#!/usr/bin/env python3
"""Validate build-specific TestFlight notes before uploading an IPA."""
import argparse
import os
from pathlib import Path
import re
import uuid


MAX_NOTES_LENGTH = 4000
BUILD_HEADER = re.compile(r'^\d+\.\d+\.\d+\s*\([1-9]\d*\)$')


def read_version(path):
    match = re.search(
        r'^version:[ \t]*(\d+\.\d+\.\d+)\+([1-9]\d*)[ \t]*$',
        path.read_text(encoding='utf-8'),
        re.MULTILINE,
    )
    if not match:
        raise ValueError('Expected pubspec.yaml version in name+build format.')
    return match.groups()


def prepare_notes(version, build_number, source, custom=''):
    if not re.fullmatch(r'\d+\.\d+\.\d+', version):
        raise ValueError('Version must have the format major.minor.patch.')
    if not re.fullmatch(r'[1-9]\d*', build_number):
        raise ValueError('Build number must be a positive integer.')
    expected = f'{version} ({build_number})'
    override = custom.strip()
    text = (override or source).strip()
    if not text:
        raise ValueError('TestFlight release notes are empty.')
    first, _, rest = text.partition('\n')
    if not override or BUILD_HEADER.fullmatch(first.strip()):
        if first.strip() != expected:
            raise ValueError(
                f'Update TestFlight notes for this build: expected header "{expected}".'
            )
        body = rest.strip()
    else:
        body = text
    if not body:
        raise ValueError('TestFlight notes must describe the changes, not only the version.')
    notes = f'{expected}\n\n{body}'
    if len(notes) > MAX_NOTES_LENGTH:
        raise ValueError(f'Keep TestFlight notes within {MAX_NOTES_LENGTH} characters.')
    return notes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pubspec', type=Path, default=Path('pubspec.yaml'))
    parser.add_argument('--version')
    parser.add_argument('--build-number')
    parser.add_argument('--notes-file', type=Path, default=Path('docs/testflight-release-notes.txt'))
    parser.add_argument('--output', type=Path, default=Path('build/ios/testflight-release-notes.txt'))
    args = parser.parse_args()
    try:
        source_version, source_build = read_version(args.pubspec)
        version = args.version or source_version
        build_number = args.build_number or source_build
        custom = os.environ.get('CUSTOM_RELEASE_NOTES', '').strip()
        source = '' if custom else args.notes_file.read_text(encoding='utf-8-sig')
        notes = prepare_notes(version, build_number, source, custom)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(notes + '\n', encoding='utf-8')
    if os.environ.get('GITHUB_OUTPUT'):
        delimiter = 'notes_' + uuid.uuid4().hex
        with open(os.environ['GITHUB_OUTPUT'], 'a', encoding='utf-8') as output:
            output.write(f'notes<<{delimiter}\n{notes}\n{delimiter}\n')
    print(f'Prepared TestFlight release notes for {version} ({build_number}).')


if __name__ == '__main__':
    main()
