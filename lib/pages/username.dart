import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/auth_controller.dart';
import '../util/routes/app_routes.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _continue() async {
    final username = _controller.text.trim();
    if (username.length < 6) {
      setState(() => _error = 'usernameTooShort'.tr);
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      setState(() => _error = 'usernameInvalid'.tr);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = Get.find<AuthController>();
    final available = await auth.isUsernameAvailable(username);
    if (!available) {
      setState(() {
        _loading = false;
        _error = 'usernameTaken'.tr;
      });
      return;
    }
    final user = auth.user ?? U(uid: '');
    user.username = username;
    await auth.updateUser(user);
    setState(() => _loading = false);
    if (mounted) {
      Get.toNamed(AppRoutes.avatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('letsSpiceItUp'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('usernameDescription'.tr),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'username'.tr,
                hintText: 'usernameExample'.tr,
                errorText: _error,
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
