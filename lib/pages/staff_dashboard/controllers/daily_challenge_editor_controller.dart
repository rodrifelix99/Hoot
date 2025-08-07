import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/toast_service.dart';

class DailyChallengeEditorController extends GetxController {
  DailyChallengeEditorController(
      {this.createDailyChallenge, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final Future<void> Function({
    required String prompt,
    required String hashtag,
    required DateTime expiresAt,
    required DateTime createAt,
  })? createDailyChallenge;
  final FirebaseFirestore _firestore;

  final TextEditingController promptController = TextEditingController();
  final TextEditingController hashtagController = TextEditingController();
  final Rx<DateTime?> expiration = Rx<DateTime?>(null);
  final Rx<DateTime?> createAt = Rx<DateTime?>(null);
  final RxBool submitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever<DateTime?>(createAt, (date) {
      expiration.value = date?.add(const Duration(hours: 24));
    });
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    try {
      final results = await Future.wait([
        _firestore
            .collection('daily_challenges')
            .orderBy('expiresAt', descending: true)
            .limit(1)
            .get(),
        _firestore
            .collection('scheduled_daily_challenges')
            .orderBy('expiresAt', descending: true)
            .limit(1)
            .get(),
      ]);
      DateTime? maxDate;
      for (final query in results) {
        if (query.docs.isEmpty) continue;
        final doc = query.docs.first;
        final data = doc.data();
        final dynamic ts = data['expiresAt'];
        DateTime dt;
        if (ts is Timestamp) {
          dt = ts.toDate();
        } else if (ts is int) {
          dt = DateTime.fromMillisecondsSinceEpoch(ts);
        } else if (ts is DateTime) {
          dt = ts;
        } else {
          continue;
        }
        if (maxDate == null || dt.isAfter(maxDate)) {
          maxDate = dt;
        }
      }
      createAt.value = maxDate ?? DateTime.now();
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      createAt.value = DateTime.now();
    }
  }

  @override
  void onClose() {
    promptController.dispose();
    hashtagController.dispose();
    super.onClose();
  }

  Future<void> pickCreateAt() async {
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
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;
    createAt.value =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> submit() async {
    final prompt = promptController.text.trim();
    final hashtag = hashtagController.text.trim();
    final expiresAt = expiration.value;
    final creation = createAt.value;
    if (prompt.isEmpty ||
        hashtag.isEmpty ||
        expiresAt == null ||
        creation == null) {
      ToastService.showError('Please fill all fields');
      return;
    }
    submitting.value = true;
    try {
      if (createDailyChallenge != null) {
        await createDailyChallenge!(
          prompt: prompt,
          hashtag: hashtag,
          expiresAt: expiresAt,
          createAt: creation,
        );
      } else {
        final callable =
            FirebaseFunctions.instance.httpsCallable('createDailyChallenge');
        await callable.call(<String, dynamic>{
          'prompt': prompt,
          'hashtag': hashtag,
          'expiresAt': expiresAt.millisecondsSinceEpoch,
          'createAt': creation.millisecondsSinceEpoch,
        });
      }
      ToastService.showSuccess('challengeCreated'.tr);
      promptController.clear();
      hashtagController.clear();
      expiration.value = null;
      createAt.value = null;
    } catch (e, s) {
      await ErrorService.reportError(e, stack: s);
      ToastService.showError('somethingWentWrong'.tr);
    } finally {
      submitting.value = false;
    }
  }
}
