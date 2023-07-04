import 'package:flutter/material.dart';
import 'package:hoot/components/user_suggestions.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:provider/provider.dart';

import '../components/post_component.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Post> _posts = [];
  bool _isLoading = false;

  Future _getPosts() async {
    try {
      setState(() => _isLoading = true);
      await Provider.of<FeedProvider>(context, listen: false).getFeed();
      setState(() {
        _posts = Provider.of<FeedProvider>(context, listen: false).feed;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _getPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
          child: Column(
            children: [
              const UserSuggestions(),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _posts.length,
                itemBuilder: (BuildContext context, int index) {
                  return PostComponent(post: _posts[index]);
                },
              ),
            ],
          )
      ),
    );
  }
}
