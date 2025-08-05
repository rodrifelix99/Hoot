import 'package:flutter/material.dart';
import 'package:hoot/util/routes/app_routes.dart';

class LoginMockPage extends StatelessWidget {
  const LoginMockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            AppRoutes.home,
          ),
          child: const Text('Enter'),
        ),
      ),
    );
  }
}
