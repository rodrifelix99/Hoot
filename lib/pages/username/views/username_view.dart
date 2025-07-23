import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/routes/app_routes.dart';
import '../controllers/username_controller.dart';

class UsernameView extends GetView<UsernameController> {
  const UsernameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('letsSpiceItUp'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('usernameDescription'.tr),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.avatar),
              child: Text('continueButton'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
