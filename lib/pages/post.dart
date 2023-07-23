import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/components/empty_message.dart';
import 'package:hoot/components/post_component.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/error_service.dart';

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
  bool _loadingLikes = false;

  @override
  void initState() {
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    super.initState();
    widget.post == null ? _getPost() : _getLikes(DateTime.now());
  }

  Future _getPost() async {
    setState(() => _loading = true);
    widget.post = await _feedProvider.getPost(widget.userId!, widget.feedId!, widget.postId!);
    setState(() => _loading = false);
    await _getLikes(DateTime.now());
  }

  Future _getLikes(DateTime startAfter, { bool refresh = false }) async {
    try {
      if (widget.post!.likers.isEmpty && !refresh) {
        setState(() => _loadingLikes = true);
      }
      List<U> likes = await _feedProvider.getLikes(widget.post!.user!.uid, widget.post!.feed!.id, widget.post!.id, startAfter);
      setState(() => widget.post!.likers = likes);
    } catch (e) {
      print(e);
      ToastService.showToast(context, "Error getting likes", true);
    } finally {
      setState(() => _loadingLikes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.post?.user != null ? Text('Hoot by @${widget.post?.user?.username}') : Text('Hoot'),
      ),
      body:_loading ? Center(
        child: LoadingAnimationWidget.inkDrop(
          size: 50,
          color: Theme.of(context).primaryColor,
        ),

      ) : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostComponent(post: widget.post!),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Text('Likes', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 10),
              _loadingLikes ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SkeletonListTile(
                      leadingStyle: const SkeletonAvatarStyle(
                        shape: BoxShape.circle,
                        width: 50,
                        height: 50,
                      ),
                    ),
                    SkeletonListTile(
                      leadingStyle: const SkeletonAvatarStyle(
                        shape: BoxShape.circle,
                        width: 50,
                        height: 50,
                      ),
                    ),
                    SkeletonListTile(
                      leadingStyle: const SkeletonAvatarStyle(
                        shape: BoxShape.circle,
                        width: 50,
                        height: 50,
                      ),
                    ),
                    SkeletonListTile(
                      leadingStyle: const SkeletonAvatarStyle(
                        shape: BoxShape.circle,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ) : widget.post!.likers.isEmpty ? const Center(
                child: NothingToShowComponent(
                  icon: Icon(Icons.heart_broken_rounded),
                  text: 'No likes yet',
                )
              ) : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.post!.likers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => Navigator.pushNamed(context, '/profile', arguments: widget.post!.likers[index]),
                    leading: ProfileAvatar(
                        image: widget.post!.likers[index].smallProfilePictureUrl ?? '',
                        size: 50,
                        radius: (widget.post!.likers[index].radius ?? 100)/3
                      ),
                    title: Text(widget.post!.likers[index].name ?? ''),
                    subtitle: Text("@${widget.post!.likers[index].username}"),
                  );
                },
              )
            ],
          )
      ),
    );
  }
}
