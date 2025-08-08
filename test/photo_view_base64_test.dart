import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import 'package:hoot/pages/photo_view/controllers/photo_view_controller.dart';
import 'package:hoot/pages/photo_view/views/photo_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;

  testWidgets('displays base64 image', (tester) async {
    const base64Image =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=';
    Get.put(PhotoZoomViewController(imageUrl: base64Image));
    await tester.pumpWidget(const GetMaterialApp(home: PhotoZoomView()));
    await tester.pump();
    final photoView = tester.widget<PhotoView>(find.byType(PhotoView));
    expect(photoView.imageProvider, isA<MemoryImage>());
    Get.reset();
  });
}
