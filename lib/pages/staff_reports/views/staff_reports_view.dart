import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/pages/staff_reports/controllers/staff_reports_controller.dart';

class StaffReportsView extends GetView<StaffReportsController> {
  const StaffReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'reports'.tr,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.reports.isEmpty) {
          return Center(
            child: NothingToShowComponent(
              icon: const Icon(Icons.report_gmailerrorred_outlined),
              text: 'noReports'.tr,
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.reports.length,
          itemBuilder: (context, index) {
            final report = controller.reports[index];
            return ListTile(
              title: Text(report.type),
              subtitle: Text(report.reason),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    tooltip: 'dismiss'.tr,
                    onPressed: () => controller.dismiss(report.id),
                  ),
                  if (report.type == 'post')
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'removePost'.tr,
                      onPressed: () => controller.removePost(report),
                    ),
                  IconButton(
                    icon: const Icon(Icons.warning),
                    tooltip: 'warnUser'.tr,
                    onPressed: () => controller.warnUser(report),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
