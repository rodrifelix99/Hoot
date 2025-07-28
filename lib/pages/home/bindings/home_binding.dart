import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../feed/controllers/feed_controller.dart';
import '../../explore/controllers/explore_controller.dart';
import '../../create_post/controllers/create_post_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => FeedController());
    Get.lazyPut(() => ExploreController());
    Get.lazyPut(() => CreatePostController());
    Get.lazyPut(() => NotificationsController());
    Get.lazyPut(() => ProfileController(), tag: 'current');
  }
}
