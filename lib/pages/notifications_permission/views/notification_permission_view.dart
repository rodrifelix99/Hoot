import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_permission_controller.dart';

class NotificationPermissionView
    extends GetView<NotificationPermissionController> {
  const NotificationPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('enableNotifications'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'notificationsPermission'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.requestPermission,
              child: Text('continueButton'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
