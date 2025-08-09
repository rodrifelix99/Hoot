import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hoot/services/analytics_service.dart';

/// A [NavigatorObserver] that logs screen views using [AnalyticsService].
class AnalyticsRouteObserver extends GetObserver {
  AnalyticsRouteObserver({AnalyticsService? analytics})
      : _analytics = analytics ?? Get.find<AnalyticsService>();

  final AnalyticsService _analytics;

  void _log(Route? route) {
    final name = route?.settings.name;
    if (name != null && name.isNotEmpty) {
      _analytics.logScreenView(name);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _log(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _log(previousRoute);
  }
}
