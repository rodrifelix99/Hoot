import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../util/routes/app_routes.dart';

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

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      return RouteSettings(
        name: AppRoutes.login,
      );
    }

    // User is authenticated, allow access to the requested route
    return null;
  }
}
