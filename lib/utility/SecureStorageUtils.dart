import 'package:shared_preferences/shared_preferences.dart';
import 'encrypted_box_key.dart';
import 'dart:developer';

import 'package:discuz_flutter/entity/DiscuzAuthentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:local_auth/local_auth.dart';

import '../dao/DiscuzAuthenticationDao.dart';
import '../generated/l10n.dart';

enum AuthenticationStatus {
  can_authenticate,
  device_not_supported,
  could_not_authenticate,
  failed,
  success
}

class SecureStorageUtils {
  static const discuz_password_storage_key = "discuz_password_storage_key";
  static const private_message_cache_storage_key =
      "private_message_cache_storage_key";

  static FlutterSecureStorage getFlutterSecureStorage() {
    AndroidOptions _getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
          resetOnError: false,
          migrateWithBackup: true,
        );
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    return storage;
  }

  static Future<bool> canAuthenticated() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool isDeviceSupported = await auth.isDeviceSupported();
    final bool canAuthenticate =
        canAuthenticateWithBiometrics && isDeviceSupported;
    log("can auth with bio? ${canAuthenticateWithBiometrics} is device supported ${isDeviceSupported}");
    return canAuthenticate;
  }

  static Future<AuthenticationStatus> getAuthenticationStatus() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool isDeviceSupported = await auth.isDeviceSupported();
    if (!isDeviceSupported) {
      return AuthenticationStatus.device_not_supported;
    } else if (!canAuthenticateWithBiometrics) {
      return AuthenticationStatus.could_not_authenticate;
    } else {
      return AuthenticationStatus.can_authenticate;
    }
  }

  static Future<bool> authenticateWithSystem(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: S.of(context).authenticateBySystem,
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      log("message ${e.code}");
      return false;
    } on Exception catch (e) {
      log("Additional message ${e}");
      return false;
    }
  }

  static Box<DiscuzAuthentication>? discuzAuthentificationBox = null;

  static String discuzAuthentificationKey = "discuzAuthentificationKey";

  static Future<Box<DiscuzAuthentication>>? _authenticationOpening;

  static Future<Box<DiscuzAuthentication>> getDiscuzAuthenticationBox() async {
    if (discuzAuthentificationBox?.isOpen == true)
      return discuzAuthentificationBox!;
    final pending = _authenticationOpening;
    if (pending != null) return pending;
    discuzAuthentificationBox = null;
    final opening = _openAuthenticationBox();
    _authenticationOpening = opening;
    try {
      return discuzAuthentificationBox = await opening;
    } finally {
      _authenticationOpening = null;
    }
  }

  static const _passwordStoreSelection = 'active_password_store';

  static Future<Box<DiscuzAuthentication>> _openAuthenticationBox() async {
    final prefs = await SharedPreferences.getInstance();
    return _openPasswordStore(prefs.getString(_passwordStoreSelection));
  }

  static Future<Box<DiscuzAuthentication>> _openPasswordStore(
      String? store) async {
    final secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        resetOnError: false,
        migrateWithBackup: true,
        storageNamespace: store,
      ),
    );
    final keyName = store == null
        ? discuz_password_storage_key
        : '${discuz_password_storage_key}_$store';
    final boxName = store == null
        ? '${discuzAuthentificationKey}_password'
        : '${discuzAuthentificationKey}_$store';
    final encryptionBase64Key = await readEncryptedBoxKey(
      read: () => secureStorage.read(key: keyName),
      write: (value) => secureStorage.write(key: keyName, value: value),
      boxExists: () => Hive.boxExists(boxName),
      generate: Hive.generateSecureKey,
    );

    return Hive.openBox<DiscuzAuthentication>(boxName,
        encryptionCipher: HiveAesCipher(encryptionBase64Key),
        crashRecovery: false);
  }

  /// Called only after explicit confirmation. Never deletes the previous store.
  static Future<DiscuzAuthenticationDao> createNewPasswordStore() async {
    final store = 'passwords_${DateTime.now().microsecondsSinceEpoch}';
    final box = await _openPasswordStore(store);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(_passwordStoreSelection, store)) {
        throw StateError('Unable to select the new password store');
      }
    } catch (_) {
      await box.close();
      rethrow;
    }
    discuzAuthentificationBox = box;
    return DiscuzAuthenticationDao(box);
  }

  static Future<DiscuzAuthenticationDao> getDiscuzAuthenticationDao() async {
    Box<DiscuzAuthentication> discuzAuthentificationBox =
        await getDiscuzAuthenticationBox();
    return DiscuzAuthenticationDao(discuzAuthentificationBox);
  }

  static Future<HiveCipher>? _privateMessageCipher;

  static Future<HiveCipher> getPrivateMessageCacheCipher() async {
    final pending = _privateMessageCipher;
    if (pending != null) return pending;
    final opening = _readPrivateMessageCacheCipher();
    _privateMessageCipher = opening;
    try {
      return await opening;
    } finally {
      _privateMessageCipher = null;
    }
  }

  static Future<HiveCipher> _readPrivateMessageCacheCipher() async {
    final storage = getFlutterSecureStorage();
    final key = await readEncryptedBoxKey(
      read: () => storage.read(key: private_message_cache_storage_key),
      write: (value) =>
          storage.write(key: private_message_cache_storage_key, value: value),
      boxExists: () =>
          Hive.boxExists('discuz_flutter_private_message_cache_v2'),
      generate: Hive.generateSecureKey,
    );
    return HiveAesCipher(key);
  }
}
