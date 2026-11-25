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
  success,
}

class SecureStorageUtils {
  static const discuz_password_storage_key = "discuz_password_storage_key";
  static const private_message_cache_storage_key =
      "private_message_cache_storage_key";

  static FlutterSecureStorage getFlutterSecureStorage() {
    final storage = FlutterSecureStorage(
      aOptions: migrationAndroidOptions(null),
    );
    return storage;
  }

  static AndroidOptions migrationAndroidOptions(String? store) =>
      AndroidOptions(
        // v9 used both plain and encrypted preferences in the default file.
        // v10 shares one native instance per file, so use identical options
        // for the password key and private-message cache key.
        // ignore: deprecated_member_use
        encryptedSharedPreferences: true,
        // ignore: deprecated_member_use
        sharedPreferencesName: store,
        migrateOnAlgorithmChange: true,
        // The v10 backup path skips ESP-only stores; keep the ESP fallback.
        migrateWithBackup: false,
        resetOnError: false,
      );

  static Future<bool> canAuthenticated() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool isDeviceSupported = await auth.isDeviceSupported();
    final bool canAuthenticate =
        canAuthenticateWithBiometrics && isDeviceSupported;
    log(
      "can auth with bio? ${canAuthenticateWithBiometrics} is device supported ${isDeviceSupported}",
    );
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

  static Future<Box<DiscuzAuthentication>> _openPasswordStore(String? store) =>
      openEncryptedBox<DiscuzAuthentication>(
        boxName: '${discuzAuthentificationKey}_${store ?? 'password'}',
        keyName: discuz_password_storage_key,
        store: store,
      );

  static Future<Box<T>> openEncryptedBox<T>({
    required String boxName,
    required String keyName,
    String? store,
  }) async {
    final secureStorage = FlutterSecureStorage(
      aOptions: migrationAndroidOptions(store),
    );
    final scopedKey = store == null ? keyName : '${keyName}_$store';
    try {
      final encryptionKey = await readEncryptedBoxKey(
        read: () => secureStorage.read(key: scopedKey),
        write: (value) => secureStorage.write(key: scopedKey, value: value),
        boxExists: () => Hive.boxExists(boxName),
        generate: Hive.generateSecureKey,
      );
      return await Hive.openBox<T>(
        boxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
        crashRecovery: false,
      );
    } catch (error, stackTrace) {
      if (isUnrecoverableEncryptionError(error)) {
        Error.throwWithStackTrace(const UnreadableEncryptedStore(), stackTrace);
      }
      rethrow;
    }
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
}
