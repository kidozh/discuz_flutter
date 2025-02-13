

import 'dart:convert';
import 'dart:developer';

import 'package:discuz_flutter/entity/DiscuzAuthentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../dao/DiscuzAuthenticationDao.dart';
import '../generated/l10n.dart';

enum AuthenticationStatus{
  can_authenticate,
  device_not_supported,
  could_not_authenticate,
  failed,
  success

}


class SecureStorageUtils{
  static const discuz_password_storage_key = "discuz_password_storage_key";

  static FlutterSecureStorage getFlutterSecureStorage(){
    AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    return storage;
  }

  static Future<bool> canAuthenticated() async{
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool isDeviceSupported = await auth.isDeviceSupported();
    final bool canAuthenticate = canAuthenticateWithBiometrics && isDeviceSupported;
    log("can auth with bio? ${canAuthenticateWithBiometrics} is device supported ${isDeviceSupported}");
    return canAuthenticate;
  }

  static Future<AuthenticationStatus> getAuthenticationStatus() async{
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool isDeviceSupported = await auth.isDeviceSupported();
    if(!isDeviceSupported){
    return AuthenticationStatus.device_not_supported;
    }
    else if(!canAuthenticateWithBiometrics){
      return AuthenticationStatus.could_not_authenticate;
    }
    else{
      return AuthenticationStatus.can_authenticate;
    }

  }

  static Future<bool> authenticateWithSystem(BuildContext context) async{
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: S.of(context).authenticateBySystem,
          options: const AuthenticationOptions(
            useErrorDialogs: true
          )
      );
      return didAuthenticate;
    } on PlatformException catch(e) {
      if(e.code == auth_error.notAvailable){

      }
      log("message ${e.code}");
      return false;
    }
  }

  static Box<DiscuzAuthentication>? discuzAuthentificationBox= null;

  static String discuzAuthentificationKey = "discuzAuthentificationKey";

  static Future<Box<DiscuzAuthentication>> getDiscuzAuthenticationBox() async {
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    String? encryptedKey = await secureStorage.read(key: discuz_password_storage_key);
    if(encryptedKey == null){
      List<int> encryptedHiveKey = Hive.generateSecureKey();
      await secureStorage.write(key: discuz_password_storage_key, value: base64UrlEncode(encryptedHiveKey));
      encryptedKey = base64UrlEncode(encryptedHiveKey);
    }
    var encryptionBase64Key = base64Url.decode(encryptedKey);

    if(discuzAuthentificationBox == null){
      discuzAuthentificationBox = await Hive.openBox<DiscuzAuthentication>(
          '${discuzAuthentificationKey}_password',
          encryptionCipher: HiveAesCipher(encryptionBase64Key)
      );
    }

    return discuzAuthentificationBox!;
  }

  static Future<DiscuzAuthenticationDao> getDiscuzAuthenticationDao() async {
    Box<DiscuzAuthentication> discuzAuthentificationBox = await getDiscuzAuthenticationBox();
    return DiscuzAuthenticationDao(discuzAuthentificationBox);
  }





}