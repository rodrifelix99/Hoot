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

  String? phoneNumber;
  bool? verified;
  bool? tester;
  DateTime? birthday;
  int? subscriptionCount;
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
    this.phoneNumber,
    this.verified = false,
    this.tester = false,
    this.birthday,
    this.subscriptionCount,
    this.feeds,
  });

  @override
  String toString() {
    return 'User $uid';
  }

  factory U.fromJson(Map<String, dynamic> json) {
    return U(
      uid: json['uid'],
      name: json['displayName']?.trim(),
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
      phoneNumber: json['phoneNumber'],
      verified: json['verified'],
      tester: json['tester'],
      birthday: json['birthday'],
      subscriptionCount: json['subscriptionCount'],
      feeds: json['feeds'] != null ? List<Feed>.from(json['feeds'].map((x) => Feed.fromJson(x))) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'phoneNumber': phoneNumber,
      'birthday': birthday,
    };
  }

  Map<String, dynamic> toCache() => {
    'uid': uid,
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
    'phoneNumber': phoneNumber,
    'birthday': birthday,
    'verified': verified,
    'tester': tester,
    'subscriptionCount': subscriptionCount,
    'feeds': feeds?.map((e) => e.toCache()).toList(),
  };
}