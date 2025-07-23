import 'package:get/get.dart';
import '../controllers/subscriptions_controller.dart';

class SubscriptionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SubscriptionsController());
  }
}
