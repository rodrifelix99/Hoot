import 'package:flutter/material.dart';
import 'package:hoot/util/routes/app_routes.dart';

import 'pages/login_mock_page.dart';
import 'pages/home_mock_page.dart';
import 'pages/profile_mock_page.dart';

final Map<String, WidgetBuilder> uiMockRoutes = {
  AppRoutes.login: (_) => const LoginMockPage(),
  AppRoutes.home: (_) => const HomeMockPage(),
  AppRoutes.profile: (_) => const ProfileMockPage(),
};
