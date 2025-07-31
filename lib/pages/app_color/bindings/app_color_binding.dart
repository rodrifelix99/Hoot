import 'package:get/get.dart';
import '../controllers/app_color_controller.dart';

class AppColorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppColorController());
  }
}
