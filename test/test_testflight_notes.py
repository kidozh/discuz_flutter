import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).parents[1] / 'scripts/prepare_testflight_notes.py'
spec = importlib.util.spec_from_file_location('testflight_notes', SCRIPT)
notes = importlib.util.module_from_spec(spec)
spec.loader.exec_module(notes)


class TestFlightNotesTests(unittest.TestCase):
    def test_matching_build_preserves_user_facing_changes(self):
        self.assertEqual(
            notes.prepare_notes('2.0.11', '168', '2.0.11 (168)\n\n- 修复设置深色模式。\n'),
            '2.0.11 (168)\n\n- 修复设置深色模式。',
        )

    def test_old_version_or_build_cannot_be_reused(self):
        for header in ['2.0.10 (168)', '2.0.11 (167)', '更新内容']:
            with self.subTest(header=header), self.assertRaises(ValueError):
                notes.prepare_notes('2.0.11', '168', header + '\n\n旧说明')

    def test_requires_changes_beyond_the_version(self):
        for text in ['', '  ', '2.0.11 (168)\n\n']:
            with self.subTest(text=text), self.assertRaises(ValueError):
                notes.prepare_notes('2.0.11', '168', text)

    def test_custom_notes_replace_old_file_and_receive_the_actual_build(self):
        result = notes.prepare_notes('2.0.11', '168', '2.0.10 (167)\n\n旧功能', '修复登录 Cookie 同步。')
        self.assertEqual(result, '2.0.11 (168)\n\n修复登录 Cookie 同步。')
        self.assertNotIn('旧功能', result)

    def test_versioned_custom_notes_must_also_match(self):
        with self.assertRaises(ValueError):
            notes.prepare_notes('2.0.11', '168', '', '2.0.10 (167)\n\n旧说明')
        self.assertEqual(
            notes.prepare_notes('2.0.11', '168', '', '2.0.11 (168)\n\n新说明'),
            '2.0.11 (168)\n\n新说明',
        )

    def test_rejects_invalid_versions_and_excessive_length(self):
        for version, build in [('2.0', '168'), ('2.0.11', '0'), ('2.0.11', '168\nother=value')]:
            with self.subTest(version=version, build=build), self.assertRaises(ValueError):
                notes.prepare_notes(version, build, '', '本次更新')
        with self.assertRaises(ValueError):
            notes.prepare_notes('2.0.11', '168', '', '新' * notes.MAX_NOTES_LENGTH)

    def test_cli_writes_utf8_file_and_github_multiline_output(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'pubspec.yaml').write_text('version: 2.0.11+168\n')
            (root / 'notes.txt').write_text('2.0.11 (168)\n\n- 热门板块显示真实图标和简介。\n')
            env = {**os.environ, 'GITHUB_OUTPUT': str(root / 'github-output'), 'CUSTOM_RELEASE_NOTES': ''}
            subprocess.run([
                sys.executable, str(SCRIPT), '--pubspec', str(root / 'pubspec.yaml'),
                '--notes-file', str(root / 'notes.txt'), '--output', str(root / 'out/notes.txt'),
            ], env=env, check=True, capture_output=True)
            rendered = (root / 'out/notes.txt').read_text()
            output = (root / 'github-output').read_text().splitlines()
            delimiter = output[0].removeprefix('notes<<')
            self.assertTrue(delimiter.startswith('notes_'))
            self.assertEqual(output[-1], delimiter)
            self.assertEqual('\n'.join(output[1:-1]) + '\n', rendered)

    def test_cli_fails_before_creating_output_for_stale_notes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'pubspec.yaml').write_text('version: 2.0.11+168\n')
            (root / 'notes.txt').write_text('2.0.10 (167)\n\n旧说明')
            result = subprocess.run([
                sys.executable, str(SCRIPT), '--pubspec', str(root / 'pubspec.yaml'),
                '--notes-file', str(root / 'notes.txt'), '--output', str(root / 'out.txt'),
            ], env={**os.environ, 'CUSTOM_RELEASE_NOTES': ''}, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('2.0.11 (168)', result.stderr)
            self.assertFalse((root / 'out.txt').exists())


if __name__ == '__main__':
    unittest.main()
