import 'feed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  String? invitationCode;
  String? invitedBy;
  int? invitationUses;
  DateTime? invitationLastReset;

  String? phoneNumber;
  bool? verified;
  bool? tester;
  DateTime? birthday;
  int? subscriptionCount;
  List<Feed>? feeds;

  U({
    required this.uid,
    this.name,
    this.username,
    this.smallProfilePictureUrl,
    this.largeProfilePictureUrl,
    this.bannerPictureUrl,
    this.radius,
    this.color,
    this.musicUrl,
    this.bio,
    this.location,
    this.website,
    this.invitationCode,
    this.invitedBy,
    this.invitationUses,
    this.invitationLastReset,
    this.phoneNumber,
    this.verified = false,
    this.tester = false,
    this.birthday,
    this.subscriptionCount,
    this.feeds,
  });

  bool get isNewUser => username == null || username!.isEmpty;

  bool get isUninvited =>
      invitationCode == null ||
      invitationCode!.isEmpty ||
      invitedBy == null ||
      invitedBy!.isEmpty;

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
      invitationCode: json['invitationCode'],
      invitedBy: json['invitedBy'],
      invitationUses: json['invitationUses'],
      invitationLastReset: json['invitationLastReset'] is Timestamp
          ? (json['invitationLastReset'] as Timestamp).toDate()
          : json['invitationLastReset'],
      phoneNumber: json['phoneNumber'],
      verified: json['verified'],
      tester: json['tester'],
      birthday: json['birthday'],
      subscriptionCount: json['subscriptionCount'],
      feeds: json['feeds'] != null
          ? List<Feed>.from(json['feeds'].map((x) => Feed.fromJson(x)))
          : [],
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
      'invitationCode': invitationCode,
      'invitationUses': invitationUses,
      'invitationLastReset': invitationLastReset,
      'invitedBy': invitedBy,
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
        'invitationCode': invitationCode,
        'invitationUses': invitationUses,
        'invitationLastReset': invitationLastReset,
        'invitedBy': invitedBy,
        'phoneNumber': phoneNumber,
        'birthday': birthday,
        'verified': verified,
        'tester': tester,
        'subscriptionCount': subscriptionCount,
        'feeds': feeds?.map((e) => e.toCache()).toList(),
      };
}
