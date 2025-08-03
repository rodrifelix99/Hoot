import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hoot/models/user.dart';
import 'package:hoot/services/auth_service.dart';
import 'package:hoot/util/routes/app_routes.dart';

/// Middleware that allows access only to staff users.
class StaffMiddleware extends GetMiddleware {
  final AuthService _authService = Get.find<AuthService>();

  @override
  RouteSettings? redirect(String? route) {
    final user = _authService.currentUser;
    if (user == null || user.role != UserRole.staff) {
      return RouteSettings(name: AppRoutes.home);
    }
    return null;
  }
}
