import 'package:get/get.dart';
import 'package:hoot/pages/challenge/challenge_feed_controller.dart';

class ChallengeFeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChallengeFeedController());
  }
}
