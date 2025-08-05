import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:hoot/models/feedback.dart' as fb;

/// Service to submit user feedback such as screenshots and comments and to
/// fetch feedback entries from Firestore.
class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<List<fb.Feedback>> fetchFeedbacks() async {
    final snapshot = await _firestore
        .collection('feedback')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((d) => fb.Feedback.fromJson(d.id, d.data()))
        .toList();
  }
}
