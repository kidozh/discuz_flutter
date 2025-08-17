

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ToastUtils{
  static Future<void> showSuccessfulToast(String msg) {
    return EasyLoading.showSuccess(
        msg,
        duration: Durations.medium1
    );

  }

  // static void showInfoToast(BuildContext context, String msg) {
  //   // EasyLoading.showSuccess(
  //   //   msg,
  //   // );
  //
  //   toastification.show(context: context,
  //       title: Text(msg),
  //       style: ToastificationStyle.fillColored,
  //       autoCloseDuration: const Duration(seconds: 2),
  //       showProgressBar: false,
  //       type: ToastificationType.info,
  //       icon: Icon(AppPlatformIcons(context).check),
  //       alignment: Alignment.topCenter
  //
  //
  //   );
  // }

  // static void showErrorToast(BuildContext context, String msg) {
  //   toastification.show(context: context,
  //     title: Text(msg),
  //     style: ToastificationStyle.fillColored,
  //     autoCloseDuration: const Duration(milliseconds: 500),
  //     type: ToastificationType.error
  //   );
  // }
}