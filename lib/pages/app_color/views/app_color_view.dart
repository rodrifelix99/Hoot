import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/util/enums/app_colors.dart';
import 'package:hoot/pages/app_color/controllers/app_color_controller.dart';

class AppColorView extends GetView<AppColorController> {
  const AppColorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'appColor'.tr,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Obx(() {
            final selected = controller.selectedColor;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                children: [
                  for (final color in AppColor.values)
                    GestureDetector(
                      onTap: () => controller.selectColor(color),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.color.withOpacity(0.6),
                              color.color.withOpacity(0.9),
                            ],
                          ),
                          border: selected == color
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: selected == color
                            ? const Center(
                                child: Icon(Icons.check, color: Colors.white),
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: controller.resetColor,
            child: Text('resetColor'.tr),
          ),
        ],
      ),
    );
  }
}
