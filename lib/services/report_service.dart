import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/models/report.dart';

/// Provides helpers to submit user, post and comment reports.
class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

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
      'resolved': false,
    });
  }

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
      'resolved': false,
    });
  }

  Future<void> reportComment(
      {required String commentId, required String reason}) async {
    final user = _authService.currentUser;
    if (user == null) return;
    await _firestore.collection('reports').add({
      'type': 'comment',
      'targetId': commentId,
      'userId': user.uid,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'resolved': false,
    });
  }

  Future<List<Report>> fetchReports() async {
    final snapshot = await _firestore
        .collection('reports')
        .where('resolved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) => Report.fromJson(d.id, d.data())).toList();
  }

  Future<void> resolveReport(String id, {required String action}) async {
    await _firestore.collection('reports').doc(id).update({
      'resolved': true,
      'action': action,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }
}
