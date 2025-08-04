import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
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

    final authService = Get.find<AuthService>();
    final bool isMock = authService.runtimeType.toString().contains('Mock');
    final FirebaseFirestore firestore =
        isMock ? FakeFirebaseFirestore() : FirebaseFirestore.instance;

    Get.lazyPut(() => ExploreController(
          authService: authService,
          firestore: firestore,
        ));
    Get.lazyPut(() => CreatePostController());
    Get.lazyPut(() => NotificationsController());
    Get.lazyPut(() => ProfileController(), tag: 'current');
  }
}
