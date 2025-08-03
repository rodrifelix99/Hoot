import 'package:get/get.dart';
import 'package:hoot/pages/staff_dashboard/controllers/staff_dashboard_controller.dart';

class StaffDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StaffDashboardController());
  }
}
