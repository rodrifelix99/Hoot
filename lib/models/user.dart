import 'dart:convert';

class U {
  final String uid;
  String? name;
  String? username;
  String? smallProfilePictureUrl;
  String? largeProfilePictureUrl;
  String? bannerPictureUrl;
  String? color;
  String? musicUrl;
  String? bio;
  String? location;
  String? website;
  DateTime? birthday;
  List<String?> followers = [];
  List<String?> following = [];

  U({
    required this.uid,
    this.name, this.username,
    this.smallProfilePictureUrl,
    this.largeProfilePictureUrl,
    this.bannerPictureUrl,
    this.color, this.musicUrl,
    this.bio, this.location,
    this.website,
    this.birthday,
    this.followers = const [],
    this.following = const [],
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
      color: json['color'],
      musicUrl: json['music'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      birthday: json['birthday'],
      followers: json['followers'] != null ? List<String>.from(json['followers']) : [],
      following: json['following'] != null ? List<String>.from(json['following']) : [],
    );
  }

  String toJson() {
    String json = jsonEncode({
      'displayName': name,
      'username': username,
      'smallAvatar': smallProfilePictureUrl,
      'bigAvatar': largeProfilePictureUrl,
      'banner': bannerPictureUrl,
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