import 'package:get/get.dart';
import 'package:hoot/pages/post/controllers/post_controller.dart';

class PostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PostController());
  }
}
