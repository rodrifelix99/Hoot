import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/models/post.dart';
import 'package:octo_image/octo_image.dart';

class PostComponent extends StatefulWidget {
  Post post;
  PostComponent({super.key, required this.post});

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(image: widget.post.user!.smallProfilePictureUrl ?? '', size: 50),
              const SizedBox(width: 10),
              Text(
                widget.post.user!.name!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.post.text ?? '',
            style: const TextStyle(
              fontSize: 20,
            ),
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
          Row(
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
          ),
        ],
      ),
    );
  }
}
