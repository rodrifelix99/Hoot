import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:super_clipboard/super_clipboard.dart';

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
    this.onImagePaste,
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
  final Future<void> Function(Uint8List data)? onImagePaste;

  @override
  Widget build(BuildContext context) {
    final editor = FlutterMentions(
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

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyV):
            const PasteTextIntent(SelectionChangedCause.tap),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
            const PasteTextIntent(SelectionChangedCause.tap),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PasteTextIntent: CallbackAction<PasteTextIntent>(
            onInvoke: (intent) async {
              final clipboard = SystemClipboard.instance;
              if (onImagePaste != null && clipboard != null) {
                final reader = await clipboard.read();
                final formats = [
                  Formats.png,
                  Formats.jpeg,
                  Formats.webp,
                  Formats.gif,
                  Formats.bmp,
                  Formats.tiff,
                  Formats.heic,
                  Formats.heif,
                ];
                for (final format in formats) {
                  if (reader.canProvide(format)) {
                    reader.getFile(format, (file) async {
                      final bytes = await file.readAll();
                      await onImagePaste?.call(bytes);
                    });
                    return null;
                  }
                }
              }

              final data = await Clipboard.getData(Clipboard.kTextPlain);
              final controller = mentionKey.currentState?.controller;
              if (data != null && controller != null) {
                final selection = controller.selection;
                final text = data.text ?? '';
                final newText = controller.text
                    .replaceRange(selection.start, selection.end, text);
                controller.value = controller.value.copyWith(
                  text: newText,
                  selection: TextSelection.collapsed(
                      offset: selection.start + text.length),
                  composing: TextRange.empty,
                );
              }
              return null;
            },
          ),
        },
        child: editor,
      ),
    );
  }
}
