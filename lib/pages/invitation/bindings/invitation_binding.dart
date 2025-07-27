import 'package:get/get.dart';
import '../controllers/invitation_controller.dart';

class InvitationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InvitationController());
  }
}
