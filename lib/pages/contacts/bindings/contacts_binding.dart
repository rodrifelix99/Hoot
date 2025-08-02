import 'package:get/get.dart';
import 'package:hoot/pages/contacts/controllers/contacts_controller.dart';

class ContactsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ContactsController());
  }
}
