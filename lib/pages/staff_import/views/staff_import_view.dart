import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/pages/staff_import/controllers/staff_import_controller.dart';

class StaffImportView extends GetView<StaffImportController> {
  const StaffImportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'import'.tr,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: controller.jsonController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Enter JSON data',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.importData,
              child: Text('submit'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
