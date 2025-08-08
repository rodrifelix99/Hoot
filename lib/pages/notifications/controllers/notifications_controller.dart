import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/services/error_service.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
  final Rx<PagingState<DocumentSnapshot?, HootNotification>> state =
      PagingState<DocumentSnapshot?, HootNotification>().obs;
  final RxInt unreadCount = 0.obs;
  final RxInt requestCount = 0.obs;
  final RxList<U> requestUsers = <U>[].obs;

  StreamSubscription<int>? _unreadSub;

  @override
  void onInit() {
    super.onInit();
    _loadInitialNotifications();
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
    await _loadInitialNotifications();
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

  Future<void> _loadInitialNotifications() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    state.value = state.value.reset().copyWith(isLoading: true);
    try {
      final page = await _notificationService.fetchNotifications(uid);
      state.value = state.value.copyWith(
        pages: [page.notifications],
        keys: [page.lastDoc],
        hasNextPage: page.hasMore,
        isLoading: false,
      );
      notifications.assignAll(page.notifications);
      unreadCount.value = page.notifications.where((n) => !n.read).length;
    } catch (e) {
      await ErrorService.reportError(
        e,
        message: 'somethingWentWrong'.tr,
      );
      state.value = state.value.copyWith(
        isLoading: false,
      );
    } finally {
      state.value = state.value.copyWith(isLoading: false);
    }
  }

  Future<void> fetchNext() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    final current = state.value;
    if (current.isLoading || !current.hasNextPage) return;

    state.value = current.copyWith(isLoading: true, error: null);
    try {
      final page = await _notificationService.fetchNotifications(
        uid,
        startAfter: current.keys?.last,
      );
      state.value = state.value.copyWith(
        pages: [...?current.pages, page.notifications],
        keys: [...?current.keys, page.lastDoc],
        hasNextPage: page.hasMore,
        isLoading: false,
      );
      notifications.addAll(page.notifications);
      unreadCount.value = notifications.where((n) => !n.read).length;
    } finally {
      state.value = state.value.copyWith(isLoading: false);
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
