import 'package:get/get.dart';
import '../controllers/create_feed_controller.dart';

class CreateFeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateFeedController());
  }
}
