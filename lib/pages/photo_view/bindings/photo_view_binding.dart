import 'package:get/get.dart';
import 'package:hoot/pages/photo_view/controllers/photo_view_controller.dart';

class PhotoViewBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    String url;
    if (args is Map && args['imageUrl'] != null) {
      url = args['imageUrl'];
    } else if (args is String) {
      url = args;
    } else {
      url = '';
    }
    Get.lazyPut(() => PhotoZoomViewController(imageUrl: url));
  }
}
