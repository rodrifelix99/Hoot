import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:solar_icons/solar_icons.dart';
import '../../../components/post_component.dart';
import '../../../components/comment_component.dart';
import '../../../components/mention_text_field.dart';
import '../controllers/post_controller.dart';

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PostComponent(post: controller.post),
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
                  SafeArea(child: const SizedBox(height: 32)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: LiquidGlassLayer(
                settings: const LiquidGlassSettings(
                  blur: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: LiquidGlass.inLayer(
                        shape: LiquidRoundedRectangle(
                          borderRadius: Radius.circular(16),
                        ),
                        glassContainsChild: false,
                        child: MentionTextField(
                          mentionKey: controller.commentKey,
                          suggestions: controller.mentionSuggestions,
                          hintText: 'writeSomething'.tr,
                          onSearchChanged: controller.searchUsers,
                          onChanged: (v) =>
                              controller.commentController.text = v,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    Obx(() => controller.postingComment.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : AnimatedSlide(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            offset: !controller.showSendButton.value
                                ? const Offset(2, 0)
                                : Offset.zero,
                          child: LiquidGlass.inLayer(
                              shape: LiquidOval(),
                              glassContainsChild: false,
                              child: IconButton(
                                icon: const Icon(SolarIconsBold.uploadMinimalistic),
                                onPressed: controller.publishComment,
                              ),
                            ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
