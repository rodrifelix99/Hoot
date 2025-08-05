import 'package:get/get.dart';
import 'package:hoot/models/feedback.dart' as fb;
import 'package:hoot/services/feedback_service.dart';

class StaffFeedbacksController extends GetxController {
  final FeedbackService _service = Get.isRegistered<FeedbackService>()
      ? Get.find<FeedbackService>()
      : FeedbackService();

  final RxList<fb.Feedback> feedbacks = <fb.Feedback>[].obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeedbacks();
  }

  Future<void> loadFeedbacks() async {
    loading.value = true;
    try {
      final result = await _service.fetchFeedbacks();
      feedbacks.assignAll(result);
    } finally {
      loading.value = false;
    }
  }
}
