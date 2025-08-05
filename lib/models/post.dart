import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';

class Post {
  String id;
  String? text;
  List<String>? media;
  List<String>? hashes;
  String? url;
  String? location;
  U? user;
  String? feedId;
  Feed? feed;
  bool liked;
  int? likes;
  List<U> likers;
  bool reFeeded;
  bool reFeededByMe;
  int? reFeeds;
  List<U> reFeeders;
  Post? reFeededFrom;
  int? comments;
  DateTime? createdAt;
  DateTime? updatedAt;

  String get smallAvatar =>
      feed?.smallAvatar ?? user?.smallProfilePictureUrl ?? '';
  String get largeAvatar =>
      feed?.bigAvatar ?? user?.largeProfilePictureUrl ?? '';

  String get smallAvatarHash =>
      feed?.smallAvatarHash ?? user?.smallAvatarHash ?? '';
  String get largeAvatarHash =>
      feed?.bigAvatarHash ?? user?.bigAvatarHash ?? '';

  Post({
    required this.id,
    this.text,
    this.media,
    this.hashes,
    this.url,
    this.location,
    this.user,
    this.feedId,
    this.feed,
    this.liked = false,
    this.likes,
    this.likers = const [],
    this.reFeeded = false,
    this.reFeededByMe = false,
    this.reFeededFrom,
    this.reFeeds,
    this.reFeeders = const [],
    this.comments,
    this.createdAt,
    this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      text: json['text'],
      media: json['images'] != null
          ? List<String>.from(json['images'])
          : json['gifs'] != null
              ? List<String>.from(json['gifs'])
              : null,
      hashes: json['hashes'] != null ? List<String>.from(json['hashes']) : null,
      url: json['url'],
      location: json['location'],
      feedId: json['feedId'],
      feed: json['feed'] != null ? Feed.fromJson(json['feed']) : null,
      user: json['user'] != null ? U.fromJson(json['user']) : null,
      liked: json['liked'] ?? false,
      likes: json['likes'],
      reFeeded: json['reFeeded'] ?? false,
      reFeededByMe: json['reFeededByMe'] ?? false,
      reFeeds: json['reFeeds'],
      reFeededFrom: json['reFeededFrom'] != null &&
              json['reFeededFrom'].runtimeType != String
          ? Post.fromJson(json['reFeededFrom'])
          : null,
      comments: json['comments'],
      createdAt: json['createdAt'] != null
          ? json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(
                  json['createdAt']['_seconds'] * 1000)
          : null,
      updatedAt: json['updatedAt'] != null
          ? json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(
                  json['updatedAt']['_seconds'] * 1000)
          : null,
    );
  }

  static Post empty() {
    return Post(
      id: '0',
      text: 'ABC',
      media: [],
      hashes: [],
      url: null,
      location: null,
      feedId: '0',
      feed: null,
      user: null,
      liked: false,
      likes: 0,
      reFeeded: false,
      reFeededByMe: false,
      reFeeds: 0,
      reFeededFrom: null,
      comments: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'images': media,
      'hashes': hashes,
      'feedId': feedId,
      'url': url,
      'location': location,
    };
  }

  Map<String, dynamic> toCache() {
    return {
      'id': id,
      'text': text,
      'media': media,
      'hashes': hashes,
      'feedId': feedId,
      'url': url,
      'location': location,
      'feed': feed?.toCache(),
      'user': user?.toCache(),
      'liked': liked,
      'likes': likes,
      'reFeeded': reFeeded,
      'reFeededByMe': reFeededByMe,
      'reFeeds': reFeeds,
      'reFeededFrom': reFeededFrom?.toCache(),
      'comments': comments,
      'createdAt': createdAt?.millisecondsSinceEpoch.toString(),
      'updatedAt': updatedAt?.millisecondsSinceEpoch.toString(),
    };
  }

  factory Post.fromCache(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      text: json['text'],
      media: json['media'] != null ? List<String>.from(json['media']) : null,
      hashes: json['hashes'] != null ? List<String>.from(json['hashes']) : null,
      url: json['url'],
      location: json['location'],
      feedId: json['feedId'],
      feed: json['feed'] != null ? Feed.fromJson(json['feed']) : null,
      user: json['user'] != null ? U.fromJson(json['user']) : null,
      liked: json['liked'] ?? false,
      likes: json['likes'],
      reFeeded: json['reFeeded'] ?? false,
      reFeededByMe: json['reFeededByMe'] ?? false,
      reFeeds: json['reFeeds'],
      reFeededFrom: json['reFeededFrom'] != null &&
              json['reFeededFrom'].runtimeType != String
          ? Post.fromCache(json['reFeededFrom'])
          : null,
      comments: json['comments'],
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(json['createdAt']))
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(json['updatedAt']))
          : null,
    );
  }
}
