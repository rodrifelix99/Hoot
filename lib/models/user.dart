import 'package:hoot/models/feed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Defines the role of a user.
enum UserRole { user, staff }

class U {
  final String uid;
  String? name;
  String? username;
  String? smallProfilePictureUrl;
  String? largeProfilePictureUrl;
  String? smallAvatarHash;
  String? bigAvatarHash;
  String? bannerPictureUrl;
  String? bannerHash;
  String? musicUrl;
  String? bio;
  String? location;
  String? website;
  DateTime? createdAt;

  String? invitationCode;
  String? invitedBy;
  int? invitationUses;
  DateTime? invitationLastReset;

  String? phoneNumber;
  bool? verified;
  bool? tester;
  DateTime? birthday;
  int? subscriptionCount;
  int? activityScore;
  int? popularityScore;
  int? challengeCount;
  List<Feed>? feeds;
  UserRole role;

  U({
    required this.uid,
    this.name,
    this.username,
    this.smallProfilePictureUrl,
    this.largeProfilePictureUrl,
    this.smallAvatarHash,
    this.bigAvatarHash,
    this.bannerPictureUrl,
    this.bannerHash,
    this.musicUrl,
    this.bio,
    this.location,
    this.website,
    this.createdAt,
    this.invitationCode,
    this.invitedBy,
    this.invitationUses,
    this.invitationLastReset,
    this.phoneNumber,
    this.verified = false,
    this.tester = false,
    this.birthday,
    this.subscriptionCount,
    this.activityScore = 0,
    this.popularityScore = 0,
    this.challengeCount = 0,
    this.feeds,
    this.role = UserRole.user,
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
      smallAvatarHash: json['smallAvatarHash'],
      bigAvatarHash: json['bigAvatarHash'],
      bannerPictureUrl: json['banner'],
      bannerHash: json['bannerHash'],
      musicUrl: json['music'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      createdAt: json['createdAt'] != null
          ? json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : json['createdAt'] is Map<String, dynamic> &&
                      json['createdAt']['_seconds'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      json['createdAt']['_seconds'] * 1000)
                  : json['createdAt'] is String
                      ? DateTime.fromMillisecondsSinceEpoch(
                          int.parse(json['createdAt']))
                      : json['createdAt']
          : null,
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
      activityScore: json['activityScore'],
      popularityScore: json['popularityScore'],
      challengeCount: json['challengeCount'] ?? 0,
      feeds: json['feeds'] != null
          ? List<Feed>.from(json['feeds'].map((x) => Feed.fromJson(x)))
          : [],
      role: json['role'] == 'staff' ? UserRole.staff : UserRole.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': name,
      'username': username,
      'usernameLowercase': username?.toLowerCase(),
      'smallAvatar': smallProfilePictureUrl,
      'bigAvatar': largeProfilePictureUrl,
      'smallAvatarHash': smallAvatarHash,
      'bigAvatarHash': bigAvatarHash,
      'banner': bannerPictureUrl,
      'bannerHash': bannerHash,
      'music': musicUrl,
      'bio': bio,
      'location': location,
      'website': website,
      'createdAt': createdAt,
      'invitationCode': invitationCode,
      'invitationUses': invitationUses,
      'invitationLastReset': invitationLastReset,
      'invitedBy': invitedBy,
      'phoneNumber': phoneNumber,
      'birthday': birthday,
      'role': role.name,
      'verified': verified,
      'challengeCount': challengeCount,
    };
  }

  Map<String, dynamic> toCache() => {
        'uid': uid,
        'displayName': name,
        'username': username,
        'usernameLowercase': username?.toLowerCase(),
        'smallAvatar': smallProfilePictureUrl,
        'bigAvatar': largeProfilePictureUrl,
        'smallAvatarHash': smallAvatarHash,
        'bigAvatarHash': bigAvatarHash,
        'banner': bannerPictureUrl,
        'bannerHash': bannerHash,
        'music': musicUrl,
        'bio': bio,
        'location': location,
        'website': website,
        'createdAt': createdAt?.millisecondsSinceEpoch.toString(),
        'invitationCode': invitationCode,
        'invitationUses': invitationUses,
        'invitationLastReset': invitationLastReset,
        'invitedBy': invitedBy,
        'phoneNumber': phoneNumber,
        'birthday': birthday,
        'verified': verified,
        'tester': tester,
        'subscriptionCount': subscriptionCount,
        'activityScore': activityScore,
        'popularityScore': popularityScore,
        'challengeCount': challengeCount,
        'feeds': feeds?.map((e) => e.toCache()).toList(),
        'role': role.name,
      };

  factory U.fromCache(Map<String, dynamic> json) {
    return U(
      uid: json['uid'],
      name: json['displayName'],
      username: json['username'],
      smallProfilePictureUrl: json['smallAvatar'],
      largeProfilePictureUrl: json['bigAvatar'],
      smallAvatarHash: json['smallAvatarHash'],
      bigAvatarHash: json['bigAvatarHash'],
      bannerPictureUrl: json['banner'],
      bannerHash: json['bannerHash'],
      musicUrl: json['music'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(json['createdAt']))
          : null,
      invitationCode: json['invitationCode'],
      invitedBy: json['invitedBy'],
      invitationUses: json['invitationUses'],
      invitationLastReset: json['invitationLastReset'],
      phoneNumber: json['phoneNumber'],
      verified: json['verified'],
      tester: json['tester'],
      birthday: json['birthday'],
      subscriptionCount: json['subscriptionCount'],
      activityScore: json['activityScore'],
      popularityScore: json['popularityScore'],
      challengeCount: json['challengeCount'] ?? 0,
      feeds: json['feeds'] != null
          ? List<Feed>.from(json['feeds'].map((x) => Feed.fromJson(x)))
          : [],
      role: json['role'] == 'staff' ? UserRole.staff : UserRole.user,
    );
  }
}
