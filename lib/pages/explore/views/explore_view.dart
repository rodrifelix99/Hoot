import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/explore_controller.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('explore'.tr),
    );
  }
}
