import 'package:flutter/material.dart';

abstract class ToastService {
  static void showToast(BuildContext context, String message, bool isFatal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isFatal ?Theme.of(context).colorScheme.onError : Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: isFatal ? Colors.red : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}