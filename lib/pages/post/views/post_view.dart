import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../components/post_component.dart';
import '../../../components/comment_component.dart';
import '../controllers/post_controller.dart';

class PostView extends GetView<PostController> {
  const PostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'appName'.tr,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostComponent(post: controller.post),
                  const SizedBox(height: 16),
                  Obx(() {
                    final state = controller.commentsState.value;
                    final comments = state.items ?? [];
                    if (state.isLoading && comments.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: comments.length + (state.hasNextPage ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == comments.length) {
                          controller.fetchNextComments();
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return CommentComponent(comment: comments[index]);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.commentController,
                    decoration: InputDecoration(
                      hintText: 'writeSomething'.tr,
                    ),
                  ),
                ),
                Obx(() => controller.postingComment.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: controller.publishComment,
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
