import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:hoot/services/error_service.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

import '../services/feed_provider.dart';

class PostComponent extends StatefulWidget {
  final Post post;
  const PostComponent({super.key, required this.post});

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  late AuthProvider _authProvider;
  late FeedProvider _feedProvider;
  bool _deleted = false;

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    super.initState();
  }

  void _handleProfileTap() {
    Navigator.of(context).pushNamed('/profile', arguments: widget.post.user);
  }

  Future _deletePost() async {
    if (widget.post.user?.uid != _authProvider.user?.uid) return;
    // confirmation dialog
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure you want to delete this hoot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              setState(() => _deleted = true);
              bool res = await _feedProvider.deletePost(widget.post.id, widget.post.feed!.id);
              if (!res) {
                ToastService.showToast(context, 'Error deleting post', true);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleMenuTap() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return widget.post.user?.uid == _authProvider.user?.uid ? ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          leading: const Icon(Icons.delete),
          title: const Text('Delete'),
          onTap: _deletePost,
        ) : ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          leading: const Icon(Icons.report),
          title: const Text('Report'),
          onTap: () => ToastService.showToast(context, 'Coming soon', false),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _deleted ? const SizedBox() : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                      onTap: _handleProfileTap,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular((widget.post.user?.radius ?? 100)/3),
                          border: Border.all(
                            color: widget.post.feed?.color ?? Colors.transparent,
                            width: 3,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                        child: ProfileAvatar(image: widget.post.user?.smallProfilePictureUrl ?? '', size: 50, radius: (widget.post.user?.radius ?? 100)/3),
                      )
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.user?.name ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${widget.post.feed?.title}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _handleMenuTap,
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                widget.post.text ?? '',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              widget.post.media != null ? Column(
                children: [
                  OctoImage(
                    image: NetworkImage(widget.post.media ?? ''),
                    placeholderBuilder: OctoPlaceholder.blurHash(
                      'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                    ),
                    errorBuilder: OctoError.icon(color: Colors.red),
                    fit: BoxFit.cover,
                    height: 300,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 10),
                ],
              ) : const SizedBox(),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Post actions (like, comment, etc) will go here in the future",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border),
                  ),
                  Text(
                    widget.post.likes?.length.toString() ?? '0',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.repeat_rounded),
                  ),
                  Text(
                    widget.post.comments?.length.toString() ?? '0',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.comment),
                  ),
                  Text(
                    widget.post.comments?.length.toString() ?? '0',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),*/
            ],
          ),
        ),
        const Divider(
          thickness: 1,
        )
      ],
    );
  }
}
