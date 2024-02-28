

import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:toastification/toastification.dart';

class ToastUtils{
  static Future<void> showSuccessfulToast(String msg) {
    return EasyLoading.showSuccess(
        msg,
    );

  }

  static void showInfoToast(BuildContext context, String msg) {
    // EasyLoading.showSuccess(
    //   msg,
    // );

    toastification.show(context: context,
        title: Text(msg),
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 2),
        showProgressBar: false,
        type: ToastificationType.info,
        icon: Icon(AppPlatformIcons(context).check),
        alignment: Alignment.topCenter


    );
  }

  static void showErrorToast(BuildContext context, String msg) {
    toastification.show(context: context,
      title: Text(msg),
      style: ToastificationStyle.fillColored,
      autoCloseDuration: const Duration(milliseconds: 500),
      type: ToastificationType.error
    );
  }
}