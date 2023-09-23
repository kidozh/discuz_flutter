

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageUtils{
  static const discuz_password_storage_key = "discuz_password_storage_key";

  static FlutterSecureStorage getFlutterSecureStorage(){
    AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    return storage;
  }





}