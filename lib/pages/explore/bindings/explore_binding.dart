import 'package:get/get.dart';
import 'package:hoot/pages/explore/controllers/explore_controller.dart';

class ExploreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExploreController());
  }
}
