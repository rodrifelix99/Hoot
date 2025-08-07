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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller.promptController,
                decoration: InputDecoration(labelText: 'prompt'.tr),
                maxLength: 280,
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.hashtagController,
                decoration: InputDecoration(labelText: 'hashtag'.tr),
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Obx(
                    () => Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('createAt'.tr),
                        subtitle: Text(
                          controller.createAt.value != null
                              ? dateFormat.format(controller.createAt.value!)
                              : 'Select creation time',
                        ),
                        onTap: controller.pickCreateAt,
                      ),
                    ),
                  ),
                  Obx(
                    () => Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('expiration'.tr),
                        subtitle: Text(
                          controller.expiration.value != null
                              ? dateFormat.format(controller.expiration.value!)
                              : '--',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
