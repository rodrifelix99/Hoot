import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:hoot/pages/staff_import/controllers/staff_import_controller.dart';

typedef FirestoreTimestamp = Timestamp;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  test('importData stores timestamps as Firestore Timestamp', () async {
    final firestore = FakeFirebaseFirestore();
    final controller = StaffImportController(firestore: firestore);
    controller.jsonController.text = '[\n'
        '{"uid":"u1","username":"user1","createdAt":"2023-01-01T00:00:00.000Z","updatedAt":1700000000000,"birthday":"2000-01-02T00:00:00.000Z","invitationLastReset":1700000000000,"lastActionAt":"2024-05-01T12:00:00.000Z","feeds":[{"id":"f1","createdAt":"2023-02-01T00:00:00.000Z","updatedAt":1700000000000,"posts":[{"id":"p1","createdAt":1700000000000,"updatedAt":"2023-03-01T00:00:00.000Z"}]}],"subscriptions":[{"id":"f2","createdAt":"2023-04-01T00:00:00.000Z"}]}'
        '\n]';

    await controller.importData();

    final userDoc = await firestore.collection('users').doc('u1').get();
    final userData = userDoc.data()!;
    expect(userData['createdAt'], isA<FirestoreTimestamp>());
    expect(userData['updatedAt'], isA<FirestoreTimestamp>());
    expect(userData['birthday'], isA<FirestoreTimestamp>());
    expect(userData['invitationLastReset'], isA<FirestoreTimestamp>());
    expect(userData['lastActionAt'], isA<FirestoreTimestamp>());

    final feedData =
        (await firestore.collection('feeds').doc('f1').get()).data()!;
    expect(feedData['createdAt'], isA<FirestoreTimestamp>());
    expect(feedData['updatedAt'], isA<FirestoreTimestamp>());

    final postData =
        (await firestore.collection('posts').doc('p1').get()).data()!;
    expect(postData['createdAt'], isA<FirestoreTimestamp>());
    expect(postData['updatedAt'], isA<FirestoreTimestamp>());

    final subData = (await firestore
            .collection('users')
            .doc('u1')
            .collection('subscriptions')
            .doc('f2')
            .get())
        .data()!;
    expect(subData['createdAt'], isA<FirestoreTimestamp>());
  });
}
