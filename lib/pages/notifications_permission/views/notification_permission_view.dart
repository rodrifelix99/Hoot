import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/pages/notifications_permission/controllers/notification_permission_controller.dart';

class NotificationPermissionView
    extends GetView<NotificationPermissionController> {
  const NotificationPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'enableNotifications'.tr,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/notification.webp',
                width: 200,
                height: 200,
              ),
              const Spacer(),
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
      ),
    );
  }
}
