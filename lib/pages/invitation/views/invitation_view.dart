import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/invitation_controller.dart';

class InvitationView extends GetView<InvitationController> {
  const InvitationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('invitationCode'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'invitationCodePrompt'.tr,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.codeController,
              decoration: InputDecoration(labelText: 'invitationCode'.tr),
            ),
            const SizedBox(height: 16),
            Obx(
              () => ElevatedButton(
                onPressed:
                    controller.verifying.value ? null : controller.verifyCode,
                child: controller.verifying.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('continueButton'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
