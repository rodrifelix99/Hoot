import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/toast_service.dart';

class DailyChallengeEditorController extends GetxController {
  final TextEditingController promptController = TextEditingController();
  final TextEditingController hashtagController = TextEditingController();
  final Rx<DateTime?> expiration = Rx<DateTime?>(null);
  final RxBool submitting = false.obs;

  @override
  void onClose() {
    promptController.dispose();
    hashtagController.dispose();
    super.onClose();
  }

  Future<void> pickExpiration() async {
    final now = DateTime.now();
    final context = Get.context!;
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) return;
    expiration.value =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> submit() async {
    final prompt = promptController.text.trim();
    final hashtag = hashtagController.text.trim();
    final expiresAt = expiration.value;
    if (prompt.isEmpty || hashtag.isEmpty || expiresAt == null) {
      ToastService.showError('Please fill all fields');
      return;
    }
    submitting.value = true;
    try {
      await FirebaseFirestore.instance.collection('daily_challenges').add({
        'prompt': prompt,
        'hashtag': hashtag,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'createdAt': FieldValue.serverTimestamp(),
      });
      ToastService.showSuccess('challengeCreated'.tr);
      promptController.clear();
      hashtagController.clear();
      expiration.value = null;
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      ToastService.showError('somethingWentWrong'.tr);
    } finally {
      submitting.value = false;
    }
  }
}
