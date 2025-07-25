import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../controllers/edit_feed_controller.dart';
import '../../../util/enums/feed_types.dart';

class EditFeedView extends GetView<EditFeedController> {
  const EditFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'editFeed'.tr,
        actions: [
          Obx(
            () => controller.saving.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : TextButton(
                    onPressed: () async {
                      final result = await controller.save();
                      if (result) Get.back();
                    },
                    child: Text('done'.tr),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(labelText: 'title'.tr),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.descriptionController,
              decoration: InputDecoration(labelText: 'description'.tr),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Obx(() => Row(
                  children: [
                    Text('${'color'.tr}:'),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final color = await showColorPickerDialog(
                          context,
                          controller.selectedColor.value,
                          barrierDismissible: true,
                        );
                        controller.selectedColor.value = color;
                      },
                      child: ColorIndicator(
                        color: controller.selectedColor.value,
                        width: 40,
                        height: 40,
                        borderRadius: 20,
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButton2<FeedType>(
                value: controller.selectedType.value,
                hint: Text('genre'.tr),
                isExpanded: true,
                onChanged: (value) => controller.selectedType.value = value,
                items: FeedType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text('${FeedTypeExtension.toEmoji(t)} '
                              '${FeedTypeExtension.toTranslatedString(context, t)}'),
                        ))
                    .toList(),
                dropdownStyleData: DropdownStyleData(
                  width: MediaQuery.of(context).size.width - 32,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: controller.typeSearchController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: controller.typeSearchController,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'searchEllipsis'.tr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    final value = FeedTypeExtension.toTranslatedString(
                        context, item.value!);
                    return value
                        .toLowerCase()
                        .contains(searchValue.toLowerCase());
                  },
                ),
                onMenuStateChange: (isOpen) {
                  if (!isOpen) controller.typeSearchController.clear();
                },
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => SwitchListTile(
                  value: controller.isPrivate.value,
                  onChanged: (v) => controller.isPrivate.value = v,
                  title: Text('privateFeed'.tr),
                )),
            Obx(() => SwitchListTile(
                  value: controller.isNsfw.value,
                  onChanged: (v) => controller.isNsfw.value = v,
                  title: Text('nsfwFeed'.tr),
                )),
            const SizedBox(height: 16),
            Obx(() => controller.deleting.value
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton(
                    onPressed: () async {
                      final result =
                          await controller.deleteFeed(context);
                      if (result) Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.error,
                    ),
                    child: Text('deleteFeed'.tr),
                  )),
          ],
        ),
      ),
    );
  }
}
