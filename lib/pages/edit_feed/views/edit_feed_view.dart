import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import '../controllers/edit_feed_controller.dart';

class EditFeedView extends GetView<EditFeedController> {
  const EditFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'editFeed'.tr,
      ),
      body: Center(
        child: Text(controller.feed.title),
      ),
    );
  }
}
