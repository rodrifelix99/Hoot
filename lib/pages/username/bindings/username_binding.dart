import 'package:get/get.dart';
import '../controllers/username_controller.dart';

class UsernameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UsernameController());
  }
}
