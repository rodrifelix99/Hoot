import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contacts_controller.dart';

class ContactsView extends GetView<ContactsController> {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('contacts'.tr),
      ),
      body: Center(
        child: Text('contacts'.tr),
      ),
    );
  }
}
