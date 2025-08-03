import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/models/report.dart';

/// Provides helpers to submit user and post reports.
abstract class BaseReportService {
  Future<void> reportPost({required String postId, required String reason});
  Future<void> reportUser({required String userId, required String reason});
  Future<List<Report>> fetchReports();
  Future<void> resolveReport(String id, {required String action});
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
      'resolved': false,
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
      'resolved': false,
    });
  }

  @override
  Future<List<Report>> fetchReports() async {
    final snapshot = await _firestore
        .collection('reports')
        .where('resolved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) => Report.fromJson(d.id, d.data())).toList();
  }

  @override
  Future<void> resolveReport(String id, {required String action}) async {
    await _firestore.collection('reports').doc(id).update({
      'resolved': true,
      'action': action,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }
}
