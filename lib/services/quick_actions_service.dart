import 'package:get/get.dart';
import 'package:quick_actions/quick_actions.dart';
import '../util/routes/app_routes.dart';
import '../pages/home/controllers/home_controller.dart';

class QuickActionsService extends GetxService {
  final QuickActions _quickActions = const QuickActions();
  String? _pendingAction;

  Future<void> init() async {
    _quickActions.initialize((type) {
      _pendingAction = type;
    });
    await _quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_create_hoot',
        localizedTitle: 'Create Hoot',
        icon: 'ic_create_hoot',
      ),
      const ShortcutItem(
        type: 'action_create_feed',
        localizedTitle: 'Create Feed',
        icon: 'ic_create_feed',
      ),
      const ShortcutItem(
        type: 'action_view_notifications',
        localizedTitle: 'Notifications',
        icon: 'ic_notifications',
      ),
    ]);
  }

  void handlePendingAction() {
    final action = _pendingAction;
    if (action == null) return;
    _pendingAction = null;
    switch (action) {
      case 'action_create_hoot':
        Get.toNamed(AppRoutes.createPost);
        break;
      case 'action_create_feed':
        Get.toNamed(AppRoutes.createFeed);
        break;
      case 'action_view_notifications':
        if (Get.currentRoute != AppRoutes.home) {
          Get.offAllNamed(AppRoutes.home);
        }
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().changeIndex(2);
        }
        break;
    }
  }
}
