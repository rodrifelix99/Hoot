import 'package:get/get.dart';
import 'package:hoot/pages/staff_reports/controllers/staff_reports_controller.dart';

class StaffReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StaffReportsController());
  }
}
