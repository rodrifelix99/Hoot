import 'package:get/get.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:hoot/app/controllers/feed_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<FeedController>(FeedController(), permanent: true);
  }
}
