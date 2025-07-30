import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hoot/components/like_button_component.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tapping like button triggers haptic feedback', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LikeButtonComponent(
          liked: false,
          onTap: () {},
        ),
      ),
    ));

    await tester.tap(find.byType(LikeButtonComponent));
    await tester.pump();

    expect(calls.any((c) => c.method == 'HapticFeedback.vibrate'), isTrue);

    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });
}
