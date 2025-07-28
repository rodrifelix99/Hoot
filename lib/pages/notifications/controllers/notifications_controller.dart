import 'package:get/get.dart';

import '../../../models/hoot_notification.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';

class NotificationsController extends GetxController {
  final AuthService _authService;
  final BaseNotificationService _notificationService;

  NotificationsController({
    AuthService? authService,
    BaseNotificationService? notificationService,
  })  : _authService = authService ?? Get.find<AuthService>(),
        _notificationService = notificationService ?? NotificationService();

  final RxList<HootNotification> notifications = <HootNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
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
}
