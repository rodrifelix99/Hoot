import 'package:get/get.dart';
import 'package:hoot/pages/home/controllers/home_controller.dart';
import 'package:hoot/pages/feed/controllers/feed_controller.dart';
import 'package:hoot/pages/explore/controllers/explore_controller.dart';
import 'package:hoot/pages/create_post/controllers/create_post_controller.dart';
import 'package:hoot/pages/notifications/controllers/notifications_controller.dart';
import 'package:hoot/pages/profile/controllers/profile_controller.dart';
import 'package:hoot/services/auth_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => FeedController());
    Get.lazyPut(() => ExploreController(authService: Get.find<AuthService>()));
    Get.lazyPut(() => CreatePostController());
    Get.lazyPut(() => NotificationsController());
    Get.lazyPut(() => ProfileController(), tag: 'current');
  }
}
