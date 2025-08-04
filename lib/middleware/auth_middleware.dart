import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hoot/services/auth_service.dart';
import 'package:hoot/util/routes/app_routes.dart';

/// Middleware that redirects unauthenticated users to the login page.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Routes accessible without authentication
    const openRoutes = {
      AppRoutes.login,
      AppRoutes.terms,
      AppRoutes.aboutUs,
    };

    if (openRoutes.contains(route)) {
      return null; // Allow access to open routes
    }

    final user = Get.find<AuthService>().currentUser;
    if (user == null) {
      return RouteSettings(
        name: AppRoutes.login,
      );
    }

    // User is authenticated, allow access to the requested route
    return null;
  }
}
