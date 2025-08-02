import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/pages/report/controllers/report_controller.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('report'.tr),
      ),
      body: Center(
        child: Text('report'.tr),
      ),
    );
  }
}
