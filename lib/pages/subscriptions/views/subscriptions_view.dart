import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscriptions_controller.dart';

class SubscriptionsView extends GetView<SubscriptionsController> {
  const SubscriptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('subscriptions'.tr),
      ),
      body: Center(
        child: Text('subscriptions'.tr),
      ),
    );
  }
}
