import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/post_controller.dart';
import '../../../components/post_component.dart';

class PostView extends GetView<PostController> {
  const PostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('post'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: PostComponent(post: controller.post),
      ),
    );
  }
}
