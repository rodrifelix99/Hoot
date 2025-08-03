import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/models/comment.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hoot/components/comment_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/mention_text_field.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/pages/post/controllers/post_controller.dart';

class PostView extends GetView<PostController> {
  const PostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'appName'.tr,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: CustomScrollView(
                slivers: [
                  Obx(() {
                    final post = controller.post.value;
                    return SliverToBoxAdapter(
                      child: PostComponent(
                        post: post,
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }),
                  Obx(() {
                    final state = controller.commentsState.value;
                    return PagedSliverList<DocumentSnapshot?, Comment>(
                      state: state,
                      fetchNextPage: controller.fetchNextComments,
                      builderDelegate: PagedChildBuilderDelegate<Comment>(
                        itemBuilder: (context, item, index) =>
                            CommentComponent(comment: item),
                        firstPageProgressIndicatorBuilder: (_) => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        newPageProgressIndicatorBuilder: (_) => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        firstPageErrorIndicatorBuilder: (_) =>
                            NothingToShowComponent(
                          icon: const Icon(Icons.error_outline),
                          text: 'somethingWentWrong'.tr,
                        ),
                        noItemsFoundIndicatorBuilder: (_) =>
                            const SizedBox.shrink(),
                      ),
                    );
                  }),
                  SliverToBoxAdapter(
                    child: SafeArea(child: const SizedBox(height: 120)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: MentionTextField(
                      mentionKey: controller.commentKey,
                      suggestions: controller.mentionSuggestions,
                      hintText: 'writeSomething'.tr,
                      onSearchChanged: controller.searchUsers,
                      onChanged: (v) => controller.commentController.text = v,
                      maxLines: 1,
                    ),
                  ),
                  Obx(() => controller.postingComment.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                        icon: const Icon(Icons.send_rounded),
                        onPressed: controller.publishComment,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
