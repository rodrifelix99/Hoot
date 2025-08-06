import 'package:get/get.dart';
import 'package:hoot/pages/staff_dashboard/controllers/daily_challenge_editor_controller.dart';

class DailyChallengeEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DailyChallengeEditorController());
  }
}
