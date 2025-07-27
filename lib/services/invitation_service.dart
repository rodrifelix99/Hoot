import 'package:cloud_firestore/cloud_firestore.dart';

class InvitationService {
  final FirebaseFirestore _firestore;

  InvitationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> useInvitationCode(String newUserId, String code) async {
    final query = await _firestore
        .collection('users')
        .where('invitationCode', isEqualTo: code)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return false;
    final doc = query.docs.first;
    final data = doc.data();
    int uses = (data['invitationUses'] ?? 0) as int;
    final Timestamp? ts = data['invitationLastReset'];
    final now = DateTime.now();
    if (ts != null) {
      final last = ts.toDate();
      if (last.year != now.year || last.month != now.month) {
        uses = 0;
        await doc.reference.update({
          'invitationUses': 0,
          'invitationLastReset': FieldValue.serverTimestamp(),
        });
      }
    } else {
      await doc.reference.update({
        'invitationLastReset': FieldValue.serverTimestamp(),
      });
    }
    if (uses >= 5) return false;
    await doc.reference.update({
      'invitationUses': FieldValue.increment(1),
    });
    await _firestore
        .collection('users')
        .doc(newUserId)
        .set({'invitedBy': doc.id}, SetOptions(merge: true));
    return true;
  }
}
