import 'package:get/get.dart';
import '../../../services/theme_service.dart';
import '../../../util/enums/app_colors.dart';

class AppColorController extends GetxController {
  final _theme = Get.find<ThemeService>();

  AppColor get selectedColor => _theme.appColor.value;

  Future<void> selectColor(AppColor color) async {
    await _theme.updateAppColor(color);
  }

  Future<void> resetColor() async {
    await _theme.resetAppColor();
  }
}
