import importlib.util
import json
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location(
    'distribution_signing',
    Path(__file__).parents[1] / 'scripts/configure_ios_distribution_signing.py',
)
signing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(signing)


class DistributionSigningTests(unittest.TestCase):
    def test_requires_a_distribution_profile(self):
        with self.assertRaises(ValueError):
            signing.select_profile(json.dumps([{
                'type': 'IOS_APP_DEVELOPMENT', 'udid': 'dev-profile',
            }]))
        identifier = '11111111-1111-1111-1111-111111111111'
        self.assertEqual(signing.select_profile(json.dumps([{
            'type': 'IOS_APP_STORE', 'udid': identifier,
        }])), identifier)

    def test_updates_each_release_target_and_preserves_other_settings(self):
        source = '''
\t\tPHONE /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tPROVISIONING_PROFILE_SPECIFIER = "old profile";
\t\t\t\tMARKETING_VERSION = "$(FLUTTER_BUILD_NAME)";
\t\t\t};
\t\t};
\t\tWATCH /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tWATCHOS_DEPLOYMENT_TARGET = 10.0;
\t\t\t};
\t\t};
'''
        objects = {}
        for app, config, bundle in [
            ('runner', 'PHONE', 'com.example.app'),
            ('watch', 'WATCH', 'com.example.watch'),
        ]:
            objects[app] = {'isa': 'PBXNativeTarget', 'buildConfigurationList': app + '_configs'}
            objects[app + '_configs'] = {'buildConfigurations': [config]}
            objects[config] = {'name': 'Release', 'buildSettings': {'PRODUCT_BUNDLE_IDENTIFIER': bundle}}
        result = signing.configure_project(source, {'objects': objects}, {
            'com.example.app': 'phone-profile', 'com.example.watch': 'watch-profile',
        })
        self.assertEqual(result.count('CODE_SIGN_STYLE = "Manual";'), 2)
        self.assertEqual(result.count('CODE_SIGN_IDENTITY = "Apple Distribution";'), 2)
        self.assertIn('PROVISIONING_PROFILE_SPECIFIER = "phone-profile";', result)
        self.assertIn('PROVISIONING_PROFILE_SPECIFIER = "watch-profile";', result)
        self.assertIn('WATCHOS_DEPLOYMENT_TARGET = 10.0;', result)
        self.assertIn('MARKETING_VERSION = "$(FLUTTER_BUILD_NAME)";', result)

    def test_fails_if_a_profile_has_no_embedded_app_target(self):
        with self.assertRaises(ValueError):
            signing.configure_project('', {'objects': {}}, {'missing.app': 'profile'})


if __name__ == '__main__':
    unittest.main()
