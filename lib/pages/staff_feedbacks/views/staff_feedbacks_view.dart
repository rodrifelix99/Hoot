import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/pages/staff_feedbacks/controllers/staff_feedbacks_controller.dart';
import 'package:hoot/util/routes/app_routes.dart';
import 'package:hoot/util/image_utils.dart';

class StaffFeedbacksView extends GetView<StaffFeedbacksController> {
  const StaffFeedbacksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'feedbacks'.tr,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.feedbacks.isEmpty) {
          return Center(
            child: NothingToShowComponent(
              icon: const Icon(Icons.feedback_outlined),
              text: 'noFeedbacks'.tr,
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.feedbacks.length,
          itemBuilder: (context, index) {
            final fb = controller.feedbacks[index];
            return ListTile(
              leading: fb.screenshot != null
                  ? GestureDetector(
                      onTap: () => Get.toNamed(
                        AppRoutes.photoViewer,
                        arguments: {'imageUrl': fb.screenshot},
                      ),
                      child: isBase64ImageData(fb.screenshot!)
                          ? Image.memory(
                              decodeBase64Image(fb.screenshot!),
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              fb.screenshot!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                    )
                  : null,
              title: Text(fb.message),
              onTap: fb.screenshot != null
                  ? () => Get.toNamed(
                        AppRoutes.photoViewer,
                        arguments: {'imageUrl': fb.screenshot},
                      )
                  : null,
            );
          },
        );
      }),
    );
  }
}
