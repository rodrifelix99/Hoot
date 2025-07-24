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
      return null;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
