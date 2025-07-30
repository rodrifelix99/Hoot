import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:hoot/services/auth_service.dart';

void main() {
  test('createUserDocumentIfNeeded sets default scores', () async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final service = AuthService(auth: auth, firestore: firestore);
    final user = MockUser(uid: 'u1', displayName: 'John');

    await service.createUserDocumentIfNeeded(user);

    final doc = await firestore.collection('users').doc('u1').get();
    expect(doc.get('activityScore'), 0);
    expect(doc.get('popularityScore'), 0);
  });
}
