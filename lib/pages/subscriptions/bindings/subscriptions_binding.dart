import 'package:get/get.dart';
import 'package:hoot/pages/subscriptions/controllers/subscriptions_controller.dart';

class SubscriptionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SubscriptionsController());
  }
}
