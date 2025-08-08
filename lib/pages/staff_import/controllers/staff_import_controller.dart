import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffImportController extends GetxController {
  final TextEditingController jsonController = TextEditingController();

  void importData() {
    final text = jsonController.text;
    try {
      final data = jsonDecode(text);
      debugPrint('Imported data: $data');
      Get.snackbar('Success', 'Data imported');
    } catch (_) {
      Get.snackbar('Error', 'Invalid JSON');
    }
  }

  @override
  void onClose() {
    jsonController.dispose();
    super.onClose();
  }
}
