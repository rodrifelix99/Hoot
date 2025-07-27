import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';

/// Text field with @ mention support.
class MentionTextField extends StatelessWidget {
  const MentionTextField({
    super.key,
    required this.mentionKey,
    required this.suggestions,
    this.hintText,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.onSearchChanged,
    this.onChanged,
  });

  final GlobalKey<FlutterMentionsState> mentionKey;
  final List<Map<String, dynamic>> suggestions;
  final String? hintText;
  final int? maxLength;
  final int? minLines;
  final int maxLines;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return FlutterMentions(
      key: mentionKey,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(hintText: hintText),
      onChanged: onChanged,
      onSearchChanged: (trigger, value) {
        if (trigger == '@') onSearchChanged?.call(value);
      },
      mentions: [
        Mention(
          trigger: '@',
          data: suggestions,
        ),
      ],
    );
  }
}
