import 'package:get/get.dart';
import '../../../models/post.dart';

class PostController extends GetxController {
  late Post post;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Post) {
      post = args;
    } else if (args is Map && args['post'] is Post) {
      post = args['post'];
    } else {
      post = Post.empty();
    }
  }
}
