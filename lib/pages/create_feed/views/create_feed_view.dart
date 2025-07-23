import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_feed_controller.dart';

class CreateFeedView extends GetView<CreateFeedController> {
  const CreateFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('createFeed'.tr),
      ),
      body: Center(
        child: Text('createFeed'.tr),
      ),
    );
  }
}
