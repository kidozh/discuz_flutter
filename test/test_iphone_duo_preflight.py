import importlib.util
import os
import plistlib
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'scripts/check_iphone_duo.py'
spec = importlib.util.spec_from_file_location('duo_check', SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class DuoPreflightTests(unittest.TestCase):
    def run_check(self, *arguments):
        return subprocess.run([sys.executable, str(SCRIPT), *arguments],
                              capture_output=True, text=True)

    def test_old_sdk_is_compatible_but_not_duo_ready(self):
        result = self.run_check('--sdk-version', '27.0')
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertIn('WARNING', result.stdout)
        strict = self.run_check('--sdk-version', '27.0', '--require-duo')
        self.assertEqual(strict.returncode, 1)
        self.assertIn('27.1', strict.stdout)

    def test_supported_sdk_passes(self):
        result = self.run_check('--sdk-version', '27.1', '--require-duo')
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_built_app_sdk_overrides_host_sdk(self):
        with tempfile.TemporaryDirectory() as directory:
            app = Path(directory)
            with (app / 'Info.plist').open('wb') as target:
                plistlib.dump({'DTSDKName': 'iphoneos27.0',
                              'MinimumOSVersion': '26.0'}, target)
            result = self.run_check('--sdk-version', '27.1', '--require-duo',
                                    '--app', str(app))
            self.assertEqual(result.returncode, 1)
            self.assertIn('iOS SDK: 27.0', result.stdout)

    def test_malformed_sdk_fails(self):
        self.assertEqual(self.run_check('--sdk-version', 'unknown').returncode, 1)

    def run_build_guard(self, sdk, require=None):
        env = dict(os.environ, SDK_VERSION=sdk)
        env.pop('REQUIRE_IPHONE_DUO', None)
        if require is not None:
            env['REQUIRE_IPHONE_DUO'] = require
        return subprocess.run(
            ['/bin/sh', str(ROOT / 'scripts/check_ios_toolchain.sh')],
            env=env, capture_output=True, text=True)

    def test_ide_build_rejects_old_actual_sdk_by_default(self):
        result = self.run_build_guard('27.0')
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn('DEVELOPER_DIR', result.stderr)

    def test_ide_build_accepts_new_actual_sdk(self):
        result = self.run_build_guard('27.1')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_compatibility_build_requires_explicit_opt_out(self):
        for value in ['0', 'false']:
            result = self.run_build_guard('27.0', require=value)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn('WARNING', result.stdout)


if __name__ == '__main__':
    unittest.main()
