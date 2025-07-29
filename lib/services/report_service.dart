import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'auth_service.dart';

/// Provides helpers to submit user and post reports.
abstract class BaseReportService {
  Future<void> reportPost({required String postId, required String reason});
  Future<void> reportUser({required String userId, required String reason});
}

class ReportService implements BaseReportService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  ReportService({FirebaseFirestore? firestore, AuthService? authService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? Get.find<AuthService>();

  @override
  Future<void> reportPost(
      {required String postId, required String reason}) async {
    final user = _authService.currentUser;
    if (user == null) return;
    await _firestore.collection('reports').add({
      'type': 'post',
      'targetId': postId,
      'userId': user.uid,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> reportUser(
      {required String userId, required String reason}) async {
    final user = _authService.currentUser;
    if (user == null) return;
    await _firestore.collection('reports').add({
      'type': 'user',
      'targetId': userId,
      'userId': user.uid,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
