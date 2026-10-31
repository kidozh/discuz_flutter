import importlib.util
import plistlib
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('ios_keychain_check', ROOT / 'scripts/check_ios_keychain.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class IosKeychainPreflightTests(unittest.TestCase):
    bundle = 'com.example.forum'
    application = 'TEAM.com.example.forum'

    def test_reads_xcode_simulated_entitlements_in_macho_word_order(self):
        expected = {'application-identifier': self.application,
                    'keychain-access-groups': [self.application]}
        data = plistlib.dumps(expected)
        full_words = len(data) // 4 * 4
        words = ' '.join(f'{int.from_bytes(data[i:i+4], "little"):08x}'
                         for i in range(0, full_words, 4))
        words += ' ' + ' '.join(f'{byte:02x}' for byte in data[full_words:])
        self.assertEqual(module.simulator_entitlements(
            'Contents of (__TEXT,__entitlements) section\n0000000100000000\t' + words), expected)

    def test_unsigned_simulator_artifact_is_rejected(self):
        self.assertTrue(module.validate_entitlements(self.bundle, {}))

    def test_signature_keeps_existing_default_keychain_group(self):
        self.assertEqual(module.validate_entitlements(self.bundle, {
            'application-identifier': self.application,
            'keychain-access-groups': [self.application],
        }), [])

    def test_group_without_application_identity_is_rejected(self):
        self.assertTrue(module.validate_entitlements(self.bundle, {
            'keychain-access-groups': [self.application],
        }))

    def test_different_or_wildcard_group_cannot_hide_default_group_loss(self):
        for groups in [['TEAM.*'], ['TEAM.another-app'], []]:
            self.assertTrue(module.validate_entitlements(self.bundle, {
                'application-identifier': self.application,
                'keychain-access-groups': groups,
            }))

    def test_identity_must_match_the_installed_bundle(self):
        self.assertTrue(module.validate_entitlements(self.bundle, {
            'application-identifier': 'TEAM.other-app',
            'keychain-access-groups': ['TEAM.other-app'],
        }))


if __name__ == '__main__':
    unittest.main()
