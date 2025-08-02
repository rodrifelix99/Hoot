import 'package:get/get.dart';
import 'package:hoot/pages/subscribers/controllers/subscribers_controller.dart';

class SubscribersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SubscribersController());
  }
}
