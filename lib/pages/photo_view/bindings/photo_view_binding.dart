import 'package:get/get.dart';
import 'package:hoot/pages/photo_view/controllers/photo_view_controller.dart';

class PhotoViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PhotoZoomViewController(imageUrl: Get.arguments['imageUrl']));
  }
}