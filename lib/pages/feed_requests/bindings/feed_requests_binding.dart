import 'package:get/get.dart';
import '../controllers/feed_requests_controller.dart';

class FeedRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeedRequestsController());
  }
}
