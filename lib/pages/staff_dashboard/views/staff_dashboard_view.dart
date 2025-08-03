import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/pages/staff_dashboard/controllers/staff_dashboard_controller.dart';

class StaffDashboardView extends GetView<StaffDashboardController> {
  const StaffDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'dashboard'.tr,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = controller.stats.value;
        if (stats == null) {
          return Center(child: Text('noData'.tr));
        }
        return ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.people),
              title: Text('totalUsers'.tr),
              trailing: Text('${stats.totalUsers}'),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text('activeUsers'.tr),
              trailing: Text('${stats.activeUsers}'),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: Text('reports'.tr),
              trailing: Text('${stats.reportsCount}'),
            ),
          ],
        );
      }),
    );
  }
}
