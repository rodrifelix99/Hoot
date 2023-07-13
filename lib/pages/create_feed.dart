import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../services/error_service.dart';
import '../services/feed_provider.dart';

class CreateFeedPage extends StatefulWidget {
  const CreateFeedPage({super.key});

  @override
  State<CreateFeedPage> createState() => _CreateFeedPageState();
}

class _CreateFeedPageState extends State<CreateFeedPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Color color = Colors.blue;
  bool private = false;
  bool nsfw = false;
  bool _isLoading = false;

  bool _isValid() => _titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty;

  Future _createFeed() async {
    if (!_isValid()) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createFeed),
        ),
        body: _isLoading ? const Center(child: CircularProgressIndicator()) :
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                maxLength: 20,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLength: 280,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.description,
                ),
              ),
              const SizedBox(height: 16),
              ColorPicker(
                  onColorChanged: (Color color) => setState(() => this.color = color),
                  enableShadesSelection: false,
                  enableTonalPalette: false,
                  color: color,
                  heading: Text(
                    "Select a color for your feed",
                    style: Theme.of(context).textTheme.labelLarge,
                  )
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: private,
                    onChanged: (value) => setState(() => private = value!),
                  ),
                  Text("Private feed"),
                  const SizedBox(width: 8),
                  private ? LineIcon(LineIcons.lock) : LineIcon(LineIcons.lockOpen),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: nsfw,
                    onChanged: (value) => setState(() => nsfw = value!),
                  ),
                  Text("NSFW feed"),
                  const SizedBox(width: 8),
                  nsfw ? LineIcon(LineIcons.exclamationTriangle) : LineIcon(LineIcons.sun),
                ],
              ),
              const SizedBox(height: 26),
              ElevatedButton(
                onPressed: _createFeed,
                child: Text(AppLocalizations.of(context)!.createFeed),
              ),
              const SizedBox(height: 26),
            ],
          ),
        )
    );
  }
}
