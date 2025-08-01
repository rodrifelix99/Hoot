import 'package:get/get.dart';
import 'package:hoot/pages/feed_page/controllers/feed_page_controller.dart';
import 'package:hoot/util/routes/args/feed_page_args.dart';

class FeedPageBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as FeedPageArgs?;
    Get.lazyPut(() => FeedPageController(args: args));
  }
}
