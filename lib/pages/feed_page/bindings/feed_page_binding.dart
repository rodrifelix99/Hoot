import 'package:get/get.dart';
import '../controllers/feed_page_controller.dart';
import '../../../util/routes/args/feed_page_args.dart';

class FeedPageBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as FeedPageArgs?;
    Get.lazyPut(() => FeedPageController(args: args));
  }
}
