import 'package:get/get.dart';
import 'package:hoot/pages/invite_friends/controllers/invite_friends_controller.dart';

class InviteFriendsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InviteFriendsController());
  }
}
