import 'dart:convert';

class U {
  final String uid;
  String? name;
  String? username;
  String? smallProfilePictureUrl;
  String? largeProfilePictureUrl;
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
      'bio': bio,
      'location': location,
      'website': website,
      'birthday': birthday,
    });
    return json;
  }
}