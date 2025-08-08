import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/util/routes/app_routes.dart';

/// Simple dashboard for staff users.
class StaffHomeView extends StatelessWidget {
  const StaffHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'staff'.tr,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text('dashboard'.tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Get.toNamed(AppRoutes.staffDashboard),
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: Text('reports'.tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Get.toNamed(AppRoutes.staffReports),
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: Text('feedbacks'.tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Get.toNamed(AppRoutes.staffFeedbacks),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: Text('import'.tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Get.toNamed(AppRoutes.staffImport),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text('dailyChallenge'.tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Get.toNamed(AppRoutes.dailyChallengeEditor),
          ),
        ],
      ),
    );
  }
}
