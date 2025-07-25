import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_feed_controller.dart';

class EditFeedView extends GetView<EditFeedController> {
  const EditFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('editFeed'.tr),
      ),
      body: Center(
        child: Text(controller.feed.title),
      ),
    );
  }
}
