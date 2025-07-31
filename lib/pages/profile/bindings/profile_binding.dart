import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../util/routes/args/profile_args.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as ProfileArgs?;
    Get.lazyPut(() => ProfileController(args: args),
        tag: args?.uid ?? 'current');
  }
}
