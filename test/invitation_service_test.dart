import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hoot/services/invitation_service.dart';

void main() {
  test('useInvitationCode assigns code when none exists', () async {
    final firestore = FakeFirebaseFirestore();
    final service = InvitationService(firestore: firestore);
    await firestore.collection('users').doc('u1').set({
      'invitationCode': 'CODE',
      'invitationUses': 0,
      'invitationLastReset': Timestamp.now(),
    });
    await firestore.collection('users').doc('new').set({});

    final result = await service.useInvitationCode('new', 'CODE');

    expect(result, isTrue);
    final newUser = await firestore.collection('users').doc('new').get();
    expect(newUser.get('invitedBy'), 'u1');
    expect(newUser.get('invitationCode'), isNotEmpty);
  });

  test('getRemainingInvites returns remaining invites', () async {
    final firestore = FakeFirebaseFirestore();
    final service = InvitationService(firestore: firestore);
    await firestore.collection('users').doc('u1').set({
      'invitationUses': 2,
      'invitationLastReset': Timestamp.fromDate(DateTime.now()),
    });
    final remaining = await service.getRemainingInvites('u1');
    expect(remaining, 3);
  });

  test('getRemainingInvites resets on new month', () async {
    final firestore = FakeFirebaseFirestore();
    final service = InvitationService(firestore: firestore);
    final lastMonth = DateTime.now().subtract(const Duration(days: 31));
    await firestore.collection('users').doc('u1').set({
      'invitationUses': 4,
      'invitationLastReset': Timestamp.fromDate(lastMonth),
    });
    final remaining = await service.getRemainingInvites('u1');
    expect(remaining, 5);
    final doc = await firestore.collection('users').doc('u1').get();
    expect(doc.get('invitationUses'), 0);
  });
}
