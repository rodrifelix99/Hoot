import 'package:get/get.dart';
import 'package:hoot/pages/profile/controllers/profile_controller.dart';
import 'package:hoot/util/routes/args/profile_args.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as ProfileArgs?;
    Get.lazyPut(() => ProfileController(args: args),
        tag: args?.uid ?? 'current');
  }
}
