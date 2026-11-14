#!/usr/bin/env python3
"""Check that a stable GitHub Release matches the source version and notes."""
import argparse
import json
import os
from pathlib import Path

from prepare_testflight_notes import prepare_notes, read_version


def prepare_release(tag):
    version, build = read_version(Path('pubspec.yaml'))
    expected_tag = f'v{version}+{build}'
    if tag != expected_tag:
        raise ValueError(f'Release tag must be {expected_tag} at this commit.')

    source = Path('docs/testflight-release-notes.txt').read_text(encoding='utf-8-sig')
    prepare_notes(version, build, source)
    notes_file = Path(f'docs/releases/{version}.md')
    heading, _, body = notes_file.read_text(encoding='utf-8').partition('\n')
    if not heading.rstrip().endswith(f'{version} ({build})'):
        raise ValueError(f'{notes_file} must have a heading ending with {version} ({build}).')
    lines = []
    for line in body.splitlines():
        if line.startswith('## '):
            break
        if line.startswith('- '):
            lines.append(f'• {line[2:].strip()}')
    notes = '\n'.join(lines)
    if not notes or len(notes) > 500:
        raise ValueError(f'{notes_file} must contain 1–500 characters of user-facing release notes.')
    return {'version': version, 'build': build, 'notes': notes}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--tag', required=True)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    try:
        release = prepare_release(args.tag)
        if args.output:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(json.dumps(release, ensure_ascii=False) + '\n', encoding='utf-8')
        if os.environ.get('GITHUB_OUTPUT'):
            with open(os.environ['GITHUB_OUTPUT'], 'a', encoding='utf-8') as output:
                for field in ('version', 'build'):
                    print(f'{field}={release[field]}', file=output)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    print(f'Validated store release {args.tag}.')


if __name__ == '__main__':
    main()
