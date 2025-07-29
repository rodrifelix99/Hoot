import 'package:get/get.dart';
import '../controllers/feed_page_controller.dart';

class FeedPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeedPageController());
  }
}
