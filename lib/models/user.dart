import 'dart:convert';

import 'feed.dart';

class U {
  final String uid;
  String? name;
  String? username;
  String? smallProfilePictureUrl;
  String? largeProfilePictureUrl;
  String? bannerPictureUrl;
  double? radius;
  String? color;
  String? musicUrl;
  String? bio;
  String? location;
  String? website;
  DateTime? birthday;
  List<String?> followers = [];
  List<String?> following = [];
  List<Feed>? feeds;

  U({
    required this.uid,
    this.name, this.username,
    this.smallProfilePictureUrl,
    this.largeProfilePictureUrl,
    this.bannerPictureUrl,
    this.radius,
    this.color, this.musicUrl,
    this.bio, this.location,
    this.website,
    this.birthday,
    this.followers = const [],
    this.following = const [],
    this.feeds,
  });

  @override
  String toString() {
    return 'User $uid';
  }

  factory U.fromJson(Map<String, dynamic> json) {
    return U(
      uid: json['uid'],
      name: json['displayName'],
      username: json['username'],
      smallProfilePictureUrl: json['smallAvatar'],
      largeProfilePictureUrl: json['bigAvatar'],
      bannerPictureUrl: json['banner'],
      radius: double.tryParse(json['radius'].toString()),
      color: json['color'],
      musicUrl: json['music'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      birthday: json['birthday'],
      followers: json['followers'] != null ? List<String>.from(json['followers']) : [],
      following: json['following'] != null ? List<String>.from(json['following']) : [],
      feeds: json['feeds'] != null ? List<Feed>.from(json['feeds'].map((x) => Feed.fromJson(x))) : [],
    );
  }

  String toJson() {
    String json = jsonEncode({
      'displayName': name,
      'username': username,
      'smallAvatar': smallProfilePictureUrl,
      'bigAvatar': largeProfilePictureUrl,
      'banner': bannerPictureUrl,
      'radius': radius,
      'color': color,
      'music': musicUrl,
      'bio': bio,
      'location': location,
      'website': website,
      'birthday': birthday,
    });
    return json;
  }
}