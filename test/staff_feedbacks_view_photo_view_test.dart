import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:hoot/models/feedback.dart' as fb;
import 'package:hoot/pages/staff_feedbacks/controllers/staff_feedbacks_controller.dart';
import 'package:hoot/pages/staff_feedbacks/views/staff_feedbacks_view.dart';
import 'package:hoot/pages/photo_view/views/photo_view.dart';
import 'package:hoot/pages/photo_view/bindings/photo_view_binding.dart';
import 'package:hoot/pages/photo_view/controllers/photo_view_controller.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/services/feedback_service.dart';

class FakeFeedbackService implements BaseFeedbackService {
  @override
  Future<List<fb.Feedback>> fetchFeedbacks() async => [
        fb.Feedback(
          id: '1',
          message: 'msg',
          screenshot: 'https://example.com/img.png',
          userId: 'u1',
          createdAt: DateTime.now(),
        ),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  testWidgets('tapping feedback navigates to photo viewer with imageUrl',
      (tester) async {
    final service = FakeFeedbackService();
    Get.put(StaffFeedbacksController(service: service));

    await tester.pumpWidget(GetMaterialApp(
      getPages: [
        GetPage(name: '/', page: () => const StaffFeedbacksView()),
        GetPage(
          name: AppRoutes.photoViewer,
          page: () => const PhotoZoomView(),
          binding: PhotoViewBinding(),
        ),
      ],
    ));
    await tester.pumpAndSettle();
    // Clear network image exceptions which can occur because tests block HTTP
    // requests by default.
    while (tester.takeException() != null) {}

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();
    while (tester.takeException() != null) {}

    final controller = Get.find<PhotoZoomViewController>();
    expect(controller.imageUrl, 'https://example.com/img.png');
    Get.reset();
  });
}
