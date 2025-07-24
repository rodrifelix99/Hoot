import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

import '../util/routes/app_routes.dart';

/// Middleware that redirects unauthenticated users to the login page.
class AuthMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    // Routes accessible without authentication
    const openRoutes = {
      AppRoutes.login,
      AppRoutes.terms,
      AppRoutes.aboutUs,
    };

    if (openRoutes.contains(route.location)) {
      return route;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return GetNavConfig.fromRoute(AppRoutes.login);
    }

    final u = await AuthService.fetchUser();
    if (u == null) {
      return GetNavConfig.fromRoute(AppRoutes.welcome);
    }

    return route;
  }
}
