import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hoot/services/user_service.dart';

void main() {
  test('isUsernameAvailable checks in lowercase', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('u1').set({
      'uid': 'u1',
      'username': 'Alice',
      'usernameLowercase': 'alice',
    });
    final service = UserService(firestore: firestore);
    expect(await service.isUsernameAvailable('ALICE'), isFalse);
    expect(await service.isUsernameAvailable('bob'), isTrue);
  });
}
