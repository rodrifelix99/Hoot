import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscribers_controller.dart';

class SubscribersView extends GetView<SubscribersController> {
  const SubscribersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('subscribers'.tr),
      ),
      body: Center(
        child: Text('subscribers'.tr),
      ),
    );
  }
}
