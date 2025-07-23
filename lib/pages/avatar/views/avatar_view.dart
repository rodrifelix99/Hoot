import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/routes/app_routes.dart';
import '../controllers/avatar_controller.dart';

class AvatarView extends GetView<AvatarController> {
  const AvatarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('almostThere'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('profilePictureDescription'.tr),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.home),
              child: Text('continueButton'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
