import 'dart:async';
import 'package:get/get.dart';

import 'package:hoot/models/hoot_notification.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/services/notification_service.dart';
import 'package:hoot/services/feed_request_service.dart';

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
  final RxList<U> requestUsers = <U>[].obs;
  final RxBool loading = false.obs;

  StreamSubscription<int>? _unreadSub;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
    _loadRequestCount();
    _loadRequestUsers();
    _listenUnreadCount();
  }

  @override
  void onClose() {
    _unreadSub?.cancel();
    super.onClose();
  }

  Future<void> refreshNotifications() async {
    await _loadNotifications();
    await _loadRequestCount();
    await _loadRequestUsers();
  }

  Future<void> markAllAsRead() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _notificationService.markAllAsRead(uid);
    notifications.value = [
      for (final n in notifications)
        n.read
            ? n
            : HootNotification(
                id: n.id,
                user: n.user,
                feed: n.feed,
                postId: n.postId,
                type: n.type,
                read: true,
                createdAt: n.createdAt,
              )
    ];
    unreadCount.value = 0;
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

  void _listenUnreadCount() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    _unreadSub = _notificationService
        .unreadCountStream(uid)
        .listen((c) => unreadCount.value = c);
  }

  Future<void> _loadRequestCount() async {
    requestCount.value = await _feedRequestService.pendingRequestCount();
  }

  Future<void> _loadRequestUsers() async {
    final requests = await _feedRequestService.fetchRequestsForMyFeeds();
    final sorted = [...requests]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    requestUsers.value =
        sorted.map((r) => r.user).take(3).toList(growable: false);
  }
}
