import 'package:get/get.dart';
import 'package:hoot/pages/explore/controllers/explore_controller.dart';
import 'package:hoot/services/auth_service.dart';

class ExploreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExploreController(authService: Get.find<AuthService>()));
  }
}
