import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:hoot/models/feedback.dart' as fb;

/// Abstraction for feedback operations.
abstract class BaseFeedbackService {
  /// Fetches feedback documents from Firestore.
  Future<List<fb.Feedback>> fetchFeedbacks();
}

/// Service to submit user feedback such as screenshots and comments and to
/// fetch feedback entries from Firestore.
class FeedbackService implements BaseFeedbackService {
  FeedbackService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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

  @override
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
