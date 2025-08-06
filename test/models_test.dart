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
        'smallAvatar': 's.png',
        'bigAvatar': 'b.png',
        'smallAvatarHash': 'shash',
        'bigAvatarHash': 'bhash',
        'color': '123',
        'type': 'general',
      };
      final userJson = {
        'uid': 'u1',
        'displayName': 'John',
        'username': 'john',
        'smallAvatar': 's.png',
        'bigAvatar': 'b.png',
        'smallAvatarHash': 'uhash',
        'bigAvatarHash': 'ubhash',
        'banner': 'ban.png',
        'radius': 1,
        'color': 'blue',
        'music': 'm',
        'bio': 'bio',
        'location': 'loc',
        'website': 'w',
        'createdAt': DateTime(2020, 1, 1),
        'invitationCode': 'ABCDEF',
        'invitationUses': 1,
        'invitationLastReset': DateTime(2020, 1, 1),
        'invitedBy': 'u0',
        'phoneNumber': '123',
        'verified': true,
        'tester': false,
        'birthday': DateTime(2020, 1, 1),
        'subscriptionCount': 2,
        'activityScore': 5,
        'popularityScore': 10,
        'feeds': [feedJson],
        'role': 'staff'
      };

      final user = U.fromJson(userJson);
      expect(user.uid, 'u1');
      expect(user.name, 'John');
      expect(user.feeds?.first.title, 'Feed');
      expect(user.smallAvatarHash, 'uhash');
      expect(user.bigAvatarHash, 'ubhash');
      expect(user.invitationCode, 'ABCDEF');
      expect(user.invitedBy, 'u0');
      expect(user.invitationUses, 1);
      expect(user.activityScore, 5);
      expect(user.popularityScore, 10);
      expect(user.createdAt, isNotNull);
      expect(user.role, UserRole.staff);

      final json = user.toJson();
      expect(json['displayName'], 'John');
      expect(json['username'], 'john');
      expect(json.containsKey('uid'), isFalse);
      expect(json['invitationCode'], 'ABCDEF');
      expect(json['smallAvatarHash'], 'uhash');
      expect(json['bigAvatarHash'], 'ubhash');
      expect(json['role'], 'staff');

      final cache = user.toCache();
      expect(cache['activityScore'], 5);
      expect(cache['popularityScore'], 10);
      expect(cache['smallAvatarHash'], 'uhash');
      expect(cache['bigAvatarHash'], 'ubhash');
      expect(cache['createdAt'], isNotNull);
      expect(cache['role'], 'staff');
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
        'smallAvatar': 's.png',
        'bigAvatar': 'avatar.png',
        'smallAvatarHash': 'fsh',
        'bigAvatarHash': 'fbh',
        'color': color.value.toString(),
        'type': 'music',
        'private': true,
        'nsfw': false,
        'verified': true,
        'subscriberCount': 5,
        'posts': [
          {'id': 'p1'}
        ]
      };

      final feed = Feed.fromJson(json);
      expect(feed.id, 'f1');
      expect(feed.color, Color(int.parse(color.value.toString())));
      expect(feed.type, FeedType.music);
      expect(feed.posts?.first.id, 'p1');
      expect(feed.smallAvatarHash, 'fsh');
      expect(feed.bigAvatarHash, 'fbh');

      final toJson = feed.toJson();
      expect(toJson['title'], 'T');
      expect(toJson['color'], feed.color!.hashCode.toString());
      expect(toJson.containsKey('id'), isFalse);
      expect(toJson['smallAvatarHash'], 'fsh');
      expect(toJson['bigAvatarHash'], 'fbh');
    });
  });

  group('Post JSON', () {
    test('fromJson handles Firestore timestamps', () {
      final json = {
        'id': 'p1',
        'text': 'hello',
        'feedId': 'f1',
        'hashes': ['h1'],
        'nsfw': true,
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
      expect(post.hashes?.first, 'h1');
      expect(post.nsfw, true);

      final toJson = post.toJson();
      expect(toJson['text'], 'hello');
      expect(toJson['feedId'], 'f1');
      expect(toJson['hashes'][0], 'h1');
      expect(toJson['nsfw'], true);
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
