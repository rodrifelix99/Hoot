import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/components/image_component.dart';
import 'package:hoot/components/name_component.dart';
import 'package:hoot/models/post.dart';

class PostComponent extends StatelessWidget {
  final Post post;

  const PostComponent({
    required this.post,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatarComponent(
                image: post.user?.smallProfilePictureUrl ?? '',
                size: 40,
                radius: 12,
              ),
              const SizedBox(width: 8),
              if (post.user != null)
                NameComponent(
                  user: post.user!,
                  size: 16,
                  feedName: post.feed?.title ?? '',
                ),
            ],
          ),
          if (post.text != null && post.text!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              post.text!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
          if (post.media != null && post.media!.isNotEmpty) ...[
            const SizedBox(height: 16),
            if (post.media!.length == 1)
              AspectRatio(
                aspectRatio: 1,
                child: ImageComponent(
                  url: post.media!.first,
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
                itemCount: post.media!.length,
                itemBuilder: (context, i) {
                  return ImageComponent(
                    url: post.media![i],
                    fit: BoxFit.cover,
                    radius: 8,
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}
