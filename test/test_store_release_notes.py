import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / 'scripts/prepare_store_release.py'


class StoreReleaseNotesTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        (self.root / 'pubspec.yaml').write_text('version: 2.0.20+178\n')
        (self.root / 'docs/releases').mkdir(parents=True)
        (self.root / 'docs/testflight-release-notes.txt').write_text(
            '2.0.20 (178)\n\n仅用于 TestFlight 的测试步骤。\n',
            encoding='utf-8',
        )

    def write_notes(self, ios='修复 iOS 的导航栏。'):
        (self.root / 'docs/releases/2.0.20.md').write_text(
            '# 谈坛 2.0.20 (178)\n\n'
            '- 支持语音草稿。\n\n'
            f'## iOS\n\n- {ios}\n\n'
            '## Android\n\n- 修复 Android 的返回手势。\n\n'
            '## 下载\n\n- 安装包链接。\n',
            encoding='utf-8',
        )

    def prepare(self, platform):
        subprocess.run(
            [sys.executable, str(SCRIPT), '--tag', 'v2.0.20+178',
             '--platform', platform, '--output', 'store-release.json'],
            cwd=self.root,
            check=True,
            capture_output=True,
        )
        return json.loads((self.root / 'store-release.json').read_text())['notes']

    def test_store_notes_only_include_shared_and_matching_platform(self):
        self.write_notes()
        self.assertEqual(self.prepare('ios'), '• 支持语音草稿。\n• 修复 iOS 的导航栏。')
        self.assertEqual(self.prepare('android'), '• 支持语音草稿。\n• 修复 Android 的返回手势。')

    def test_ios_notes_do_not_count_towards_google_play_limit(self):
        self.write_notes(ios='测试' * 275)
        self.assertGreater(len(self.prepare('ios')), 500)
        self.assertEqual(self.prepare('android'), '• 支持语音草稿。\n• 修复 Android 的返回手势。')
