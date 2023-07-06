import 'package:flutter/material.dart';

abstract class ToastService {
  static void showToast(BuildContext context, String message, bool isFatal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isFatal ? Colors.red : Colors.green,
      ),
    );
  }
}