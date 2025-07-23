import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toastification/toastification.dart';

import 'package:hoot/services/toast_service.dart';
import 'package:hoot/services/dialog_service.dart';

void main() {
  testWidgets('ToastService enqueues and removes toast', (tester) async {
    await tester.pumpWidget(
      const ToastificationWrapper(
        child: MaterialApp(
          home: Scaffold(body: SizedBox()),
        ),
      ),
    );

    ToastService.showSuccess('Hello');
    await tester.pump();

    expect(toastification.managers.values.first.notifications.length, 1);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(toastification.managers.values.first.notifications, isEmpty);
  });

  testWidgets('DialogService confirm returns true on OK', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox()),
      ),
    );

    final context = tester.element(find.byType(Scaffold));

    final future = DialogService.confirm(
      context: context,
      title: 'Title',
      message: 'Message',
      okLabel: 'OK',
      cancelLabel: 'Cancel',
    );

    await tester.pumpAndSettle();

    expect(find.text('Message'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(await future, isTrue);
  });
}
