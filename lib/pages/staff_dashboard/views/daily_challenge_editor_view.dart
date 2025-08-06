import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/pages/staff_dashboard/controllers/daily_challenge_editor_controller.dart';
import 'package:intl/intl.dart';

class DailyChallengeEditorView extends GetView<DailyChallengeEditorController> {
  const DailyChallengeEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd().add_Hm();
    return Scaffold(
      appBar: AppBarComponent(
        title: 'dailyChallenge'.tr,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.promptController,
              decoration: InputDecoration(labelText: 'prompt'.tr),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.hashtagController,
              decoration: InputDecoration(labelText: 'hashtag'.tr),
            ),
            const SizedBox(height: 16),
            Obx(
              () => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('expiration'.tr),
                subtitle: Text(
                  controller.expiration.value != null
                      ? dateFormat.format(controller.expiration.value!)
                      : 'Select expiration',
                ),
                onTap: controller.pickExpiration,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => ElevatedButton(
                onPressed:
                    controller.submitting.value ? null : controller.submit,
                child: controller.submitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('createChallenge'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
