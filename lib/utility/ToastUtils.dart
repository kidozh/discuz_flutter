

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils{
  static Future<void> showSuccessfulToast(String msg) {
    return EasyLoading.showSuccess(
        msg,
    );

  }

  static Future<bool?> showInfoToast(BuildContext context, String msg) {
    return Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.CENTER,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  static Future<bool?> showErrorToast(BuildContext context, String msg) {
    return Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.CENTER,
      backgroundColor: Theme.of(context).colorScheme.error,
      textColor: Theme.of(context).colorScheme.onError,
    );
  }
}