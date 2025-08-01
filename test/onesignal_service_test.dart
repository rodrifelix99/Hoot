import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/routes/args/feed_page_args.dart';
import 'package:hoot/util/routes/args/profile_args.dart';

import 'package:hoot/services/onesignal_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  const mainChannel = MethodChannel('OneSignal');
  const userChannel = MethodChannel('OneSignal#user');
  const iamChannel = MethodChannel('OneSignal#inappmessages');
  const notifChannel = MethodChannel('OneSignal#notifications');
  const sessionChannel = MethodChannel('OneSignal#session');
  const locationChannel = MethodChannel('OneSignal#location');
  const liveChannel = MethodChannel('OneSignal#liveactivities');
  const pushChannel = MethodChannel('OneSignal#pushsubscription');
  const debugChannel = MethodChannel('OneSignal#debug');

  final allChannels = [
    mainChannel,
    userChannel,
    iamChannel,
    notifChannel,
    sessionChannel,
    locationChannel,
    liveChannel,
    pushChannel,
    debugChannel,
  ];

  setUp(() {
    for (final c in allChannels) {
      messenger.setMockMethodCallHandler(c, (call) async {
        if (call.method == 'OneSignal#permission') return false;
        if (call.method == 'OneSignal#canRequest') return true;
        if (call.method == 'OneSignal#requestPermission') return true;
        if (call.method == 'OneSignal#pushSubscriptionToken') return null;
        if (call.method == 'OneSignal#pushSubscriptionId') return null;
        if (call.method == 'OneSignal#pushSubscriptionOptedIn') return false;
        return null;
      });
    }
  });

  tearDown(() {
    for (final c in allChannels) {
      messenger.setMockMethodCallHandler(c, null);
    }
  });

  test('init calls OneSignal.initialize', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(mainChannel, (call) async {
      calls.add(call);
      return null;
    });

    dotenv.testLoad(fileInput: 'ONESIGNAL_APP_ID=123');

    final service = OneSignalService();
    await service.init();
    await Future.delayed(Duration.zero);

    expect(calls, isNotEmpty);
    expect(calls.first.method, 'OneSignal#initialize');
    expect(calls.first.arguments, {'appId': '123'});
  });

  test('login calls OneSignal.login', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(mainChannel, (call) async {
      calls.add(call);
      return null;
    });

    final service = OneSignalService();
    await service.login('u1');
    await Future.delayed(Duration.zero);

    expect(calls, hasLength(1));
    expect(calls.first.method, 'OneSignal#login');
    expect(calls.first.arguments, {'externalId': 'u1'});
  });

  test('requestPermission calls OneSignal.requestPermission', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(notifChannel, (call) async {
      calls.add(call);
      return true;
    });

    final service = OneSignalService();
    final result = await service.requestPermission();
    await Future.delayed(Duration.zero);

    expect(result, isTrue);
    expect(calls, hasLength(1));
    expect(calls.first.method, 'OneSignal#requestPermission');
    expect(calls.first.arguments, {'fallbackToSettings': true});
  });

  testWidgets('click event opens correct route', (tester) async {
    final service = OneSignalService();
    await service.init();

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [
          GetPage(name: '/', page: () => const Placeholder()),
          GetPage(
            name: AppRoutes.post,
            page: () => const Scaffold(body: Text('post page')),
          ),
        ],
      ),
    );

    final codec = const StandardMethodCodec();
    final event = {
      'notification': {
        'notificationId': 'n1',
        'additionalData': {'postId': 'p1'},
      },
      'result': {'action_id': null, 'url': null}
    };
    final data =
        codec.encodeMethodCall(MethodCall('OneSignal#onClickNotification', event));
    messenger.handlePlatformMessage(notifChannel.name, data, (_) {});

    await tester.pumpAndSettle();

    expect(find.text('post page'), findsOneWidget);
  });
}
