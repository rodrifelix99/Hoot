import 'package:get/get.dart';
import 'package:hoot/pages/feed/controllers/feed_controller.dart';

class FeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeedController());
  }
}
