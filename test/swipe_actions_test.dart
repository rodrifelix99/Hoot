import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('swiping owner calls delete callback', (tester) async {
    var deleted = false;
    await tester.pumpWidget(MaterialApp(
      home: Dismissible(
        key: const Key('c1'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async => true,
        onDismissed: (_) => deleted = true,
        child: const Text('comment'),
      ),
    ));

    await tester.drag(find.byKey(const Key('c1')), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
  });

  testWidgets('swiping non-owner triggers report callback', (tester) async {
    String? reported;
    await tester.pumpWidget(MaterialApp(
      home: Dismissible(
        key: const Key('c1'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          reported = 'reason';
          return false;
        },
        onDismissed: (_) {},
        child: const Text('comment'),
      ),
    ));

    await tester.drag(find.byKey(const Key('c1')), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(reported, 'reason');
  });
}
