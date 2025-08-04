import 'package:get/get.dart';
import 'package:hoot/pages/staff_feedbacks/controllers/staff_feedbacks_controller.dart';

class StaffFeedbacksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StaffFeedbacksController());
  }
}
