import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/models/post.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import '../util/routes/app_routes.dart';

class PostComponent extends StatefulWidget {
  final Post post;

  const PostComponent({
    required this.post,
    super.key,
  });

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  late Post _post;

  @override
  void initState() {
    _post = widget.post;
    super.initState();
  }

  void _toggleLike() {
    setState(() {
      if (_post.liked) {
        _post
          ..liked = false
          ..likes = (_post.likes ?? 1) - 1;
      } else {
        _post
          ..liked = true
          ..likes = (_post.likes ?? 0) + 1;
      }
    });
  }

  void _openPostDetails() {
    Get.toNamed(AppRoutes.post, arguments: _post);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openPostDetails,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatarComponent(
                  image: _post.user?.smallProfilePictureUrl ?? '',
                  size: 40,
                  radius: 12,
                ),
                const SizedBox(width: 8),
                if (_post.user != null)
                  NameComponent(
                    user: _post.user!,
                    size: 16,
                    feedName: _post.feed?.title ?? '',
                  ),
              ],
            ),
            if (_post.text != null && _post.text!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _post.text!,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
            if (_post.media != null && _post.media!.isNotEmpty) ...[
              const SizedBox(height: 16),
              if (_post.media!.length == 1)
                AspectRatio(
                  aspectRatio: 1,
                  child: ImageComponent(
                    url: _post.media!.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    radius: 16,
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _post.media!.length,
                  itemBuilder: (context, i) {
                    return ImageComponent(
                      url: _post.media![i],
                      fit: BoxFit.cover,
                      radius: 8,
                    );
                  },
                ),
            ],
            const SizedBox(height: 8),
            Divider(
              thickness: 1,
              color: Theme.of(context).dividerColor.withAlpha(50),
            ),
            Row(
              children: [
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    _post.liked ? SolarIconsBold.heart : SolarIconsOutline.heart,
                    color:
                        _post.liked ? Colors.red : Theme.of(context).iconTheme.color,
                  ),
                  onPressed: _toggleLike,
                ),
                if ((_post.likes ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text('${_post.likes ?? 0}'),
                  ),
                const Spacer(
                  flex: 2,
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(SolarIconsOutline.refreshSquare),
                  onPressed: () {},
                ),
                const Spacer(
                  flex: 2,
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(SolarIconsOutline.chatRoundLine),
                  onPressed: _openPostDetails,
                ),
                if ((_post.comments ?? 0) > 0)
                  Text('${_post.comments ?? 0}'),
                const Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
