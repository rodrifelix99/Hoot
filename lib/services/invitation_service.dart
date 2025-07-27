import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

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
    final userRef = _firestore.collection('users').doc(newUserId);
    await userRef.set({'invitedBy': doc.id}, SetOptions(merge: true));
    final newUserDoc = await userRef.get();
    if (!(newUserDoc.data()?.containsKey('invitationCode') ?? false)) {
      await userRef.set({
        'invitationCode': const Uuid().v4().substring(0, 8).toUpperCase(),
        'invitationUses': 0,
        'invitationLastReset': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return true;
  }
}
