import 'package:get/get.dart';
import 'package:hoot/pages/invitation/controllers/invitation_controller.dart';

class InvitationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InvitationController());
  }
}
