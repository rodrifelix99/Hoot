import 'package:get/get.dart';
import 'package:hoot/pages/staff_import/controllers/staff_import_controller.dart';

/// Binding for the staff import view.
class StaffImportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StaffImportController());
  }
}
