import 'package:hoot/models/feed.dart';
import 'package:hoot/models/user.dart';

class Post {
  String id;
  String? text;
  List<String>? media;
  U? user;
  String? feedId;
  Feed? feed;
  bool liked;
  int? likes;
  List<U> likers;
  bool reFeeded;
  int? reFeeds;
  List<U> reFeeders;
  Post? reFeededFrom;
  int? comments;
  DateTime? createdAt;
  DateTime? updatedAt;

  Post({
    required this.id,
    this.text,
    this.media,
    this.user,
    this.feedId,
    this.feed,
    this.liked = false,
    this.likes,
    this.likers = const [],
    this.reFeeded = false,
    this.reFeededFrom,
    this.reFeeds,
    this.reFeeders = const [],
    this.comments,
    this.createdAt,
    this.updatedAt,
  });

  static Post fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      text: json['text'],
      media: json['images'] != null ? List<String>.from(json['images']) : null,
      feedId: json['feedId'],
      feed: json['feed'] != null ? Feed.fromJson(json['feed']) : null,
      user: json['user'] != null ? U.fromJson(json['user']) : null,
      liked: json['liked'] ?? false,
      likes: json['likes'],
      reFeeded: json['reFeeded'] ?? false,
      reFeeds: json['reFeeds'],
      reFeededFrom: json['reFeededFrom'] != null && json['reFeededFrom'].runtimeType != String ? Post.fromJson(json['reFeededFrom']) : null,
      comments: json['comments'],
      createdAt: json['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']['_seconds'] * 1000) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']['_seconds'] * 1000) : null,
    );
  }

  static Post empty() {
    return Post(
      id: '0',
      text: 'ABC',
      media: [],
      feedId: '0',
      feed: null,
      user: null,
      liked: false,
      likes: 0,
      reFeeded: false,
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
      'feedId': feedId,
    };
  }

  Map<String, dynamic> toCache() {
    return {
      'id': id,
      'text': text,
      'images': media,
      'feedId': feedId,
      'feed': feed?.toCache(),
      'user': user?.toCache(),
      'liked': liked,
      'likes': likes,
      'reFeeded': reFeeded,
      'reFeeds': reFeeds,
      'reFeededFrom': reFeededFrom?.toCache(),
      'comments': comments,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}