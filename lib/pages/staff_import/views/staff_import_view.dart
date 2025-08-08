import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';

/// Simple placeholder view for staff imports.
class StaffImportView extends StatelessWidget {
  const StaffImportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'import'.tr,
      ),
      body: Center(
        child: Text('comingSoon'.tr),
      ),
    );
  }
}
