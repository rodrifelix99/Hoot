import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/post.dart';
import 'package:hoot/util/enums/feed_types.dart';

import 'package:hoot/models/comment.dart';
void main() {
  group('U JSON', () {
    test('fromJson and toJson round trip', () {
      final feedJson = {
        'id': 'feed1',
        'userId': 'u1',
        'title': 'Feed',
        'description': 'desc',
        'icon': 'i',
        'imageUrl': 's.png',
        'color': '123',
        'type': 'general',
      };
      final userJson = {
        'uid': 'u1',
        'displayName': 'John',
        'username': 'john',
        'smallAvatar': 's.png',
        'bigAvatar': 'b.png',
        'banner': 'ban.png',
        'radius': 1,
        'color': 'blue',
        'music': 'm',
        'bio': 'bio',
        'location': 'loc',
        'website': 'w',
        'phoneNumber': '123',
        'verified': true,
        'tester': false,
        'birthday': DateTime(2020, 1, 1),
        'subscriptionCount': 2,
        'feeds': [feedJson]
      };

      final user = U.fromJson(userJson);
      expect(user.uid, 'u1');
      expect(user.name, 'John');
      expect(user.feeds?.first.title, 'Feed');

      final json = user.toJson();
      expect(json['displayName'], 'John');
      expect(json['username'], 'john');
      expect(json.containsKey('uid'), isFalse);
    });
  });

  group('Feed JSON', () {
    test('fromJson and toJson round trip', () {
      final color = const Color(0xff0000ff);
      final json = {
        'id': 'f1',
        'userId': 'u1',
        'title': 'T',
        'description': 'D',
        'icon': 'i',
        'imageUrl': 'avatar.png',
        'color': color.value.toString(),
        'type': 'music',
        'private': true,
        'nsfw': false,
        'verified': true,
        'subscriberCount': 5,
        'requestCount': 1,
        'posts': [
          {'id': 'p1'}
        ]
      };

      final feed = Feed.fromJson(json);
      expect(feed.id, 'f1');
      expect(feed.color, Color(int.parse(color.value.toString())));
      expect(feed.type, FeedType.music);
      expect(feed.posts?.first.id, 'p1');

      final toJson = feed.toJson();
      expect(toJson['title'], 'T');
      expect(toJson['color'], feed.color!.hashCode.toString());
      expect(toJson.containsKey('id'), isFalse);
    });
  });

  group('Post JSON', () {
    test('fromJson handles Firestore timestamps', () {
      final json = {
        'id': 'p1',
        'text': 'hello',
        'feedId': 'f1',
        'liked': true,
        'likes': 2,
        'reFeeded': false,
        'reFeeds': 0,
        'comments': 0,
        'createdAt': {'_seconds': 10},
        'updatedAt': {'_seconds': 20},
      };

      final post = Post.fromJson(json);
      expect(post.createdAt, DateTime.fromMillisecondsSinceEpoch(10000));
      expect(post.updatedAt, DateTime.fromMillisecondsSinceEpoch(20000));

      final toJson = post.toJson();
      expect(toJson['text'], 'hello');
      expect(toJson['feedId'], 'f1');
      expect(toJson.containsKey('id'), isFalse);
    });
  });

  group('Comment JSON', () {
    test('fromJson and toJson round trip', () {
      final json = {
        'id': 'c1',
        'postId': 'p1',
        'text': 'Nice!',
        'user': {'uid': 'u1'},
        'createdAt': {'_seconds': 5},
        'updatedAt': {'_seconds': 6},
      };

      final comment = Comment.fromJson(json);
      expect(comment.id, 'c1');
      expect(comment.postId, 'p1');
      expect(comment.text, 'Nice!');
      expect(comment.createdAt, DateTime.fromMillisecondsSinceEpoch(5000));
      expect(comment.updatedAt, DateTime.fromMillisecondsSinceEpoch(6000));

      final toJson = comment.toJson();
      expect(toJson['text'], 'Nice!');
      expect(toJson['postId'], 'p1');
      expect(toJson.containsKey('id'), isFalse);
    });
  });
}
