import 'package:get/get.dart';
import 'package:hoot/pages/create_post/controllers/create_post_controller.dart';
import 'package:hoot/services/auth_service.dart';

class CreatePostBinding extends Bindings {
  @override
  void dependencies() {
    final authService = Get.find<AuthService>();
    final challengeId = Get.parameters['challengeId'];
    Get.lazyPut(() => CreatePostController(
          authService: authService,
          userId: authService.currentUser?.uid,
          challengeId: challengeId,
        ));
  }
}
