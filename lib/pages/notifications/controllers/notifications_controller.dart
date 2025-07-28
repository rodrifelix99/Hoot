import 'package:get/get.dart';

import '../../../models/hoot_notification.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/feed_request_service.dart';

class NotificationsController extends GetxController {
  final AuthService _authService;
  final BaseNotificationService _notificationService;
  final FeedRequestService _feedRequestService;

  NotificationsController({
    AuthService? authService,
    BaseNotificationService? notificationService,
    FeedRequestService? feedRequestService,
  })  : _authService = authService ?? Get.find<AuthService>(),
        _notificationService = notificationService ?? NotificationService(),
        _feedRequestService =
            feedRequestService ?? Get.find<FeedRequestService>();

  final RxList<HootNotification> notifications = <HootNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxInt requestCount = 0.obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
    _loadRequestCount();
  }

  Future<void> _loadNotifications() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    loading.value = true;
    try {
      final result = await _notificationService.fetchNotifications(uid);
      notifications.assignAll(result);
      unreadCount.value = result.where((n) => !n.read).length;
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadRequestCount() async {
    requestCount.value = await _feedRequestService.pendingRequestCount();
  }
}
