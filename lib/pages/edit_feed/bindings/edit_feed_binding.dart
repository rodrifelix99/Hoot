import 'package:get/get.dart';
import '../controllers/edit_feed_controller.dart';

class EditFeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditFeedController());
  }
}
