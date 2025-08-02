import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

/// Provides wrappers around common dialog patterns using the
/// [adaptive_dialog] package so dialogs look appropriate on each platform.
class DialogService {
  /// Shows a confirmation dialog returning true when the user accepts.
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    required String okLabel,
    required String cancelLabel,
  }) async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: title,
      message: message,
      okLabel: okLabel,
      cancelLabel: cancelLabel,
    );
    return result == OkCancelResult.ok;
  }

  /// Shows a confirmation dialog requiring the user to type [expectedWord]
  /// before confirming. Returns true when the word is entered correctly.
  static Future<bool> confirmWithText({
    required BuildContext context,
    required String title,
    required String message,
    required String expectedWord,
    required String okLabel,
    required String cancelLabel,
  }) async {
    final result = await showTextInputDialog(
      context: context,
      title: title,
      message: message,
      textFields: [
        DialogTextField(autocorrect: false),
      ],
      okLabel: okLabel,
      cancelLabel: cancelLabel,
    );
    final input = result?.first.trim().toLowerCase();
    return input == expectedWord.toLowerCase();
  }

  /// Shows a modal action sheet with the provided [actions].
  /// Returns the value associated with the selected action.
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<SheetAction<T>> actions,
  }) {
    return showModalActionSheet<T>(
      context: context,
      title: title,
      message: message,
      actions: actions,
    );
  }
}
