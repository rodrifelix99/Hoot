import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/auth_controller.dart';
import '../util/routes/app_routes.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> _continue() async {
    if (_controller.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('displayNameTooShort'.tr)),
      );
      return;
    }
    setState(() => _loading = true);
    final auth = Get.find<AuthController>();
    final user = auth.user ?? U(uid: '');
    user.name = _controller.text.trim();
    await auth.updateUser(user);
    setState(() => _loading = false);
    if (mounted) {
      Get.toNamed(AppRoutes.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('whatsYourName'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('displayNameDescription'.tr),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'displayName'.tr,
                hintText: 'displayNameExample'.tr,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _continue,
              child: _loading
                  ? const CircularProgressIndicator.adaptive()
                  : Text('continueButton'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
