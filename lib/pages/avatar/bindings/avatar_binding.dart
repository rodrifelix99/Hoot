import 'package:get/get.dart';
import 'package:hoot/pages/avatar/controllers/avatar_controller.dart';

class AvatarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AvatarController());
  }
}
