import 'package:get/get.dart';
import 'package:hoot/pages/username/controllers/username_controller.dart';

class UsernameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UsernameController());
  }
}
