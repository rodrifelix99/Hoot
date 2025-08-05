import 'package:flutter/material.dart';
import 'package:hoot/theme/theme.dart';
import 'package:hoot/util/routes/app_routes.dart';

import 'ui_mock_pages.dart';

void main() {
  runApp(const MockApp());
}

class MockApp extends StatelessWidget {
  const MockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hoot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(Colors.blue),
      initialRoute: AppRoutes.home,
      routes: uiMockRoutes,
    );
  }
}
