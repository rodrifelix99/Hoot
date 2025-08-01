import 'package:get/get.dart';
import 'package:hoot/pages/app_color/controllers/app_color_controller.dart';

class AppColorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppColorController());
  }
}
