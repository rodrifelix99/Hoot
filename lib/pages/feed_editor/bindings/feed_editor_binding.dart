import 'package:get/get.dart';
import 'package:hoot/pages/feed_editor/controllers/feed_editor_controller.dart';

class FeedEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FeedEditorController());
  }
}
