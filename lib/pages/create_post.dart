import 'package:flutter/material.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../models/feed.dart';
import '../services/auth_provider.dart';

class CreatePostPage extends StatefulWidget {
  String? feedId;
  CreatePostPage({super.key, this.feedId});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late FeedProvider _feedProvider;
  late AuthProvider _authProvider;
  final TextEditingController _textEditingController = TextEditingController();
  bool _isLoading = false;
  String _selectedFeedId = '';
  
  @override
  void initState() {
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
    _getFeeds();
  }

  Future _getFeeds() async {
    if (_authProvider.user!.feeds == null || _authProvider.user!.feeds!.isEmpty) {
      List<Feed> feeds = await _feedProvider.getFeeds(_authProvider.user!.uid);
      if (feeds.isEmpty) {
        Navigator.of(context).popAndPushNamed('/create_feed');
      } else {
        setState(() {
          _authProvider.user!.feeds = feeds;
          _selectedFeedId = feeds[0].id;
        });
      }
    } else {
      setState(() {
        _selectedFeedId = _authProvider.user!.feeds![0].id;
      });
    }
  }

  bool _isValid() => _textEditingController.text.isNotEmpty && _textEditingController.text.length <= 280 && _selectedFeedId.isNotEmpty;

  Future _createPost() async {
    String text = _textEditingController.text;
    if (_isValid()) {
      setState(() => _isLoading = true);
      bool code = await _feedProvider.createPost(
        feedId: _selectedFeedId,
        text: text,
      );
      if (code) {
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
          ToastService.showToast(context, AppLocalizations.of(context)!.somethingWentWrong, true);
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
          _authProvider.user!.feeds!.isNotEmpty ? DropdownButton(
            value: _selectedFeedId,
            onChanged: (value) => setState(() => _selectedFeedId = value.toString()),
            borderRadius: BorderRadius.circular(10),
            items: _authProvider.user!.feeds!.map((feed) => DropdownMenuItem(
              value: feed.id,
              child: Row(
                children: [
                  Text(feed.title),
                  const SizedBox(width: 10),
                  feed.private == true ? const LineIcon(LineIcons.lock) : const SizedBox(),
                  feed.nsfw == true ? const LineIcon(LineIcons.exclamationTriangle) : const SizedBox(),
                ],
              ),
            )).toList(),
          ) : const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 20),
          TextField(
            controller: _textEditingController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.postPlaceholder,
              contentPadding: const EdgeInsets.all(20),
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
