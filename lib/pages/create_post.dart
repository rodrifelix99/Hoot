import 'package:flutter/material.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:provider/provider.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

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
      bool code = await Provider.of<FeedProvider>(context, listen: false).createPost(text: text);
      if (code) {
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong. Please try again later.'),
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
        title: const Text('Make a Hoot'),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) :
      Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: _textEditingController,
            onChanged: (value) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
              contentPadding: EdgeInsets.all(20),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isValid() ? _createPost : null,
            child: const Text('Create Post'),
          )
        ],
      ),
    );
  }
}
