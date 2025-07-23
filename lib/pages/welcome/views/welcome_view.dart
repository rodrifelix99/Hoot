import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/routes/app_routes.dart';
import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('whatsYourName'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('displayNameDescription'.tr),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.username),
              child: Text('continueButton'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
