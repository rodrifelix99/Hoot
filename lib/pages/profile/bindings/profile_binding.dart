import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    String? uid;
    if (args is String) {
      uid = args;
    } else if (args is Map && args['uid'] is String) {
      uid = args['uid'] as String;
    }
    Get.lazyPut(() => ProfileController(), tag: uid ?? 'current');
  }
}
