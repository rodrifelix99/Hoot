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
}
