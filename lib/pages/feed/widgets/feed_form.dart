import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:hoot/services/haptic_service.dart';

import 'package:hoot/util/enums/feed_types.dart';

/// Reusable form widget for creating or editing feeds.
class FeedForm extends StatelessWidget {
  const FeedForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.typeSearchController,
    required this.selectedColor,
    required this.onColorChanged,
    required this.selectedType,
    required this.onTypeChanged,
    required this.isPrivate,
    required this.onPrivateChanged,
    required this.isNsfw,
    required this.onNsfwChanged,
  });

  /// Controller for the feed title field.
  final TextEditingController titleController;

  /// Controller for the feed description field.
  final TextEditingController descriptionController;

  /// Controller used for searching in the genre dropdown.
  final TextEditingController typeSearchController;

  /// Currently selected color.
  final Rx<Color> selectedColor;

  /// Callback when the color changes.
  final ValueChanged<Color> onColorChanged;

  /// Currently selected feed type.
  final Rx<FeedType?> selectedType;

  /// Callback when the feed type changes.
  final ValueChanged<FeedType?> onTypeChanged;

  /// Whether the feed is private.
  final RxBool isPrivate;

  /// Callback when the private flag changes.
  final ValueChanged<bool> onPrivateChanged;

  /// Whether the feed is marked NSFW.
  final RxBool isNsfw;

  /// Callback when the NSFW flag changes.
  final ValueChanged<bool> onNsfwChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: 'title'.tr),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(labelText: 'description'.tr),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Obx(() => Row(
              children: [
                Text('${'color'.tr}:'),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    HapticService.lightImpact();
                    final color = await showColorPickerDialog(
                      context,
                      selectedColor.value,
                      barrierDismissible: true,
                    );
                    onColorChanged(color);
                  },
                  child: ColorIndicator(
                    color: selectedColor.value,
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
            value: selectedType.value,
            hint: Text('genre'.tr),
            isExpanded: true,
            onChanged: onTypeChanged,
            items: FeedType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(
                      '${FeedTypeExtension.toEmoji(t)} '
                      '${FeedTypeExtension.toTranslatedString(context, t)}',
                    ),
                  ),
                )
                .toList(),
            dropdownStyleData: DropdownStyleData(
              width: MediaQuery.of(context).size.width - 32,
              padding: const EdgeInsets.symmetric(vertical: 4),
            ),
            dropdownSearchData: DropdownSearchData(
              searchController: typeSearchController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: typeSearchController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'searchEllipsis'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              searchMatchFn: (item, searchValue) {
                final value = FeedTypeExtension.toTranslatedString(
                  context,
                  item.value!,
                );
                return value.toLowerCase().contains(searchValue.toLowerCase());
              },
            ),
            onMenuStateChange: (isOpen) {
              if (!isOpen) typeSearchController.clear();
            },
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => SwitchListTile(
            value: isPrivate.value,
            onChanged: onPrivateChanged,
            title: Text('privateFeed'.tr),
          ),
        ),
        Obx(
          () => SwitchListTile(
            value: isNsfw.value,
            onChanged: onNsfwChanged,
            title: Text('nsfwFeed'.tr),
          ),
        ),
      ],
    );
  }
}
