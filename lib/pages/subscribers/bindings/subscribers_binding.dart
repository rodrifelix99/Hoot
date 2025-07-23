import 'package:get/get.dart';
import '../controllers/subscribers_controller.dart';

class SubscribersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SubscribersController());
  }
}
