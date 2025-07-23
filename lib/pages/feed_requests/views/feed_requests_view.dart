import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feed_requests_controller.dart';

class FeedRequestsView extends GetView<FeedRequestsController> {
  const FeedRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('feedRequests'.tr),
      ),
      body: Center(
        child: Text('feedRequests'.tr),
      ),
    );
  }
}
