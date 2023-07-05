import 'package:flutter/material.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreatePostPage extends StatefulWidget {
  FeedProvider feedProvider;
  CreatePostPage({super.key, required this.feedProvider});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isLoading = false;

  bool _isValid() => _textEditingController.text.isNotEmpty && _textEditingController.text.length <= 280;

  Future _createPost() async {
    String text = _textEditingController.text;
    if (_isValid()) {
      setState(() => _isLoading = true);
      bool code = await widget.feedProvider.createPost(text: text);
      if (code) {
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.somethingWentWrong),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createPost),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) :
      Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: _textEditingController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.postPlaceholder,
              contentPadding: EdgeInsets.all(20),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isValid() ? _createPost : null,
            child: Text(AppLocalizations.of(context)!.publish),
          )
        ],
      ),
    );
  }
}
