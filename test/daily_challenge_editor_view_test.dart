import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import 'package:hoot/pages/staff_dashboard/controllers/daily_challenge_editor_controller.dart';
import 'package:hoot/pages/staff_dashboard/views/daily_challenge_editor_view.dart';
import 'package:hoot/util/translations/app_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  testWidgets('renders creation selector and submits data', (tester) async {
    Map<String, dynamic>? received;
    final controller = DailyChallengeEditorController(
      createDailyChallenge: (
          {required String prompt,
          required String hashtag,
          required DateTime expiresAt,
          required DateTime createAt}) async {
        received = {
          'prompt': prompt,
          'hashtag': hashtag,
          'expiresAt': expiresAt,
          'createAt': createAt,
        };
      },
    );
    Get.put(controller);

    await tester.pumpWidget(ToastificationWrapper(
      child: GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: const DailyChallengeEditorView(),
      ),
    ));

    await tester.enterText(find.byType(TextField).at(0), 'Prompt');
    await tester.enterText(find.byType(TextField).at(1), 'Hash');

    final creation = DateTime(2025, 1, 1, 12, 0);
    final expiration = DateTime(2025, 1, 2, 12, 0);
    controller.createAt.value = creation;
    controller.expiration.value = expiration;
    await tester.pump();

    expect(find.text('Create At'), findsOneWidget);
    expect(find.text('Expiration'), findsOneWidget);

    await tester.tap(find.text('Create Challenge'));
    await tester.pump();

    expect(received, isNotNull);
    expect(received!['prompt'], 'Prompt');
    expect(received!['hashtag'], 'Hash');
    expect(received!['expiresAt'], expiration);
    expect(received!['createAt'], creation);
    await tester.pump(const Duration(seconds: 4));
    Get.reset();
  });
}
