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
            leading: const Icon(Icons.report),
            title: Text('reports'.tr),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Get.toNamed(AppRoutes.staffReports),
          ),
        ],
      ),
    );
  }
}
