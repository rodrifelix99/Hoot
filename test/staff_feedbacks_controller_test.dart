import 'package:flutter_test/flutter_test.dart';

import 'package:hoot/models/feedback.dart' as fb;
import 'package:hoot/pages/staff_feedbacks/controllers/staff_feedbacks_controller.dart';
import 'package:hoot/services/feedback_service.dart';

class FakeFeedbackService implements BaseFeedbackService {
  int fetchCalls = 0;
  List<fb.Feedback> items = [];

  @override
  Future<List<fb.Feedback>> fetchFeedbacks() async {
    fetchCalls++;
    return items;
  }
}

void main() {
  test('loadFeedbacks populates list', () async {
    final service = FakeFeedbackService();
    service.items = [
      fb.Feedback(
          id: '1',
          message: 'hello',
          screenshot: null,
          userId: 'u1',
          createdAt: DateTime.now()),
    ];
    final controller = StaffFeedbacksController(service: service);
    await controller.loadFeedbacks();
    expect(service.fetchCalls, 1);
    expect(controller.feedbacks.length, 1);
    expect(controller.feedbacks.first.message, 'hello');
  });
}
