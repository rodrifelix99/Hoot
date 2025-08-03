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
    this.textCapitalization = TextCapitalization.sentences,
    this.onSearchChanged,
    this.onChanged,
  });

  final GlobalKey<FlutterMentionsState> mentionKey;
  final List<Map<String, dynamic>> suggestions;
  final String? hintText;
  final int? maxLength;
  final int? minLines;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return FlutterMentions(
      key: mentionKey,
      suggestionPosition: SuggestionPosition.Top,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(hintText: hintText),
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      onSearchChanged: (trigger, value) {
        if (trigger == '@') onSearchChanged?.call(value);
      },
      suggestionListDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        backgroundBlendMode: BlendMode.overlay,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      mentions: [
        Mention(
          trigger: '@',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          data: suggestions,
        ),
      ],
    );
  }
}
