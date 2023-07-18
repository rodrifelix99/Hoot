import 'package:flutter/material.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';

class PostPage extends StatefulWidget {
  Post? post;
  final String? postId;
  final String? feedId;
  final String? userId;
  PostPage({super.key, this.post, this.postId, this.feedId, this.userId});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  FeedProvider _feedProvider = FeedProvider();
  bool _loading = false;
  PageController _pageViewController = PageController();

  @override
  void initState() {
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    super.initState();
    widget.post == null ? _getPost() : null;
  }

  Future _getPost() async {
    setState(() => _loading = true);
    widget.post = await _feedProvider.getPost(widget.userId!, widget.feedId!, widget.postId!);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoot'),
      ),
      body:_loading ? Center(
        child: LoadingAnimationWidget.inkDrop(
          size: 50,
          color: Theme.of(context).primaryColor,
        ),

      ) : SingleChildScrollView(
          child: Column(
            children: [
              PostComponent(post: widget.post!, showActions: false),
              MaterialSegmentedControl(
                children: <int, Widget>{
                  0: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite),
                        SizedBox(width: 8.0),
                        Text(widget.post!.likes.toString()),
                      ],
                    ),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sync_rounded),
                        SizedBox(width: 8.0),
                        Text(widget.post!.reFeeds.toString()),
                      ],
                    ),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.comment_rounded),
                        SizedBox(width: 8.0),
                        Text(widget.post!.comments.toString()),
                      ],
                    ),
                  ),
                },
                selectionIndex: _pageViewController.hasClients ? _pageViewController.page!.round() : 0,
                onSegmentTapped: (index) {
                  setState(() {
                    _pageViewController.jumpToPage(index);
                  });
                },
                borderColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).primaryColor,
                unselectedColor: Colors.white,
                borderRadius: 32.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 500,
                child: PageView(
                  controller: _pageViewController,
                  children: [
                    Container(
                      child: Center(
                        child: Text('Likes will be here'),
                      ),
                    ),
                    Container(
                      child: Center(
                        child: Text('Refeeds will be here'),
                      ),
                    ),
                    Container(
                      child: Center(
                        child: Text('Comments will be here'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}
