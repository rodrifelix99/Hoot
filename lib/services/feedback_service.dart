import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';

/// Service to submit user feedback such as screenshots and comments.
class FeedbackService {
  FeedbackService._();

  static final _functions = FirebaseFunctions.instance;

  /// Sends [screenshot] and [message] to the backend Cloud Function.
  static Future<void> submitFeedback({
    required Uint8List screenshot,
    required String message,
  }) async {
    final callable = _functions.httpsCallable('submitFeedback');
    await callable.call(<String, dynamic>{
      'screenshot': base64Encode(screenshot),
      'message': message,
    });
  }
}
