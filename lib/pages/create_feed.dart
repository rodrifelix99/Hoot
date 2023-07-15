import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../models/feed.dart';
import '../services/error_service.dart';
import '../services/feed_provider.dart';

class CreateFeedPage extends StatefulWidget {
  final Feed? feed;
  const CreateFeedPage({super.key, this.feed});

  @override
  State<CreateFeedPage> createState() => _CreateFeedPageState();
}

class _CreateFeedPageState extends State<CreateFeedPage> {
  bool _editing = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Color color = Colors.blue;
  bool private = false;
  bool nsfw = false;
  bool _isLoading = false;

  @override
  void initState() {
    _titleController.text = widget.feed?.title ?? '';
    _descriptionController.text = widget.feed?.description ?? '';
    color = widget.feed?.color ?? Colors.blue;
    private = widget.feed?.private ?? false;
    nsfw = widget.feed?.nsfw ?? false;
    _editing = widget.feed != null;
    super.initState();
  }

  bool _isValid() => _titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty;

  Future _createFeed() async {
    if (!_isValid()) {
      ToastService.showToast(context, "Make sure you fill the title and description fields", true);
      return;
    }
    setState(() => _isLoading = true);
    String feedId = await Provider.of<FeedProvider>(context, listen: false).createFeed(
        context,
        title: _titleController.text,
        description: _descriptionController.text,
        icon: 'https://picsum.photos/seed/${_titleController.text}/200/300',
        color: color,
        private: private,
        nsfw: nsfw
    );
    if (feedId.isNotEmpty) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
        ToastService.showToast(context, AppLocalizations.of(context)!.somethingWentWrong, true);
      });
    }
  }

  Future _editFeed() async {
    if (!_isValid()) return;
    setState(() => _isLoading = true);
    widget.feed?.title = _titleController.text;
    widget.feed?.description = _descriptionController.text;
    widget.feed?.color = color;
    widget.feed?.private = private;
    widget.feed?.nsfw = nsfw;
    bool res = await Provider.of<FeedProvider>(context, listen: false).editFeed(
        context,
        widget.feed!
    );
    if (res) {
      Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
        ToastService.showToast(context, AppLocalizations.of(context)!.somethingWentWrong, true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(!_editing ? AppLocalizations.of(context)!.createFeed : AppLocalizations.of(context)!.editFeed),
        ),
        body: _isLoading ? const Center(child: CircularProgressIndicator()) :
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                maxLength: 20,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLength: 280,
                maxLines: 5,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.description,
                ),
              ),
              const SizedBox(height: 16),
              ColorPicker(
                  onColorChanged: (Color color) => setState(() => this.color = color),
                  enableShadesSelection: false,
                  enableTonalPalette: false,
                  pickersEnabled: const <ColorPickerType, bool>{
                    ColorPickerType.primary: false,
                    ColorPickerType.accent: false,
                    ColorPickerType.bw: false,
                    ColorPickerType.custom: false,
                    ColorPickerType.wheel: true,
                  },
                  color: color
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 50,
                  width: 100,
                  child: Container(
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Checkbox(
                    value: private,
                    onChanged: (value) => setState(() => private = value!),
                  ),
                  const Text("Private feed"),
                  const SizedBox(width: 8),
                  private ? const LineIcon(LineIcons.lock) : const LineIcon(LineIcons.lockOpen),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: nsfw,
                    onChanged: (value) => setState(() => nsfw = value!),
                  ),
                  const Text("NSFW feed"),
                  const SizedBox(width: 8),
                  nsfw ? const LineIcon(LineIcons.exclamationTriangle) : const LineIcon(LineIcons.sun),
                ],
              ),
              const SizedBox(height: 26),
              !_editing ? ElevatedButton(
                onPressed: _isValid() ? _createFeed : null,
                child: Text(AppLocalizations.of(context)!.createFeed),
              ) : ElevatedButton(
                onPressed: _isValid() ? _editFeed : null,
                child: Text(AppLocalizations.of(context)!.editFeed),
              ),
              const SizedBox(height: 26),
            ],
          ),
        )
    );
  }
}
