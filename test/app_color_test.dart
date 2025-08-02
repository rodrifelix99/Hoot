import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hoot/pages/app_color/controllers/app_color_controller.dart';
import 'package:hoot/pages/app_color/views/app_color_view.dart';
import 'package:hoot/util/enums/app_colors.dart';
import 'package:hoot/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Selecting color updates service', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final themeService = ThemeService();
    await themeService.loadThemeSettings();
    Get.put(themeService);
    Get.put(AppColorController());

    await tester.pumpWidget(
      Obx(() => GetMaterialApp(
            theme: ThemeData.light(),
            home: const AppColorView(),
          )),
    );
    await tester.pumpAndSettle();

    expect(themeService.appColor.value, AppColor.blue);
    await tester.tap(find.byType(GestureDetector).at(1));
    await tester.pumpAndSettle();
    expect(themeService.appColor.value, AppColor.values[1]);
  });
}
