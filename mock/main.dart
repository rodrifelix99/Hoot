import 'package:flutter/material.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      routes: uiMockRoutes,
    );
  }
}
