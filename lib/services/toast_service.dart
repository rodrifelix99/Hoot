import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  ToastService._();

  static void showSuccess(String message, {String? title}) {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: title != null ? Text(title) : null,
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  static void showInfo(String message, {String? title}) {
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: title != null ? Text(title) : null,
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  static void showError(String message, {String? title}) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: title != null ? Text(title) : null,
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}
