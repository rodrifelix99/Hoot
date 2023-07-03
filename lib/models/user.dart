class U {
  final String uid;
  final String? name;
  final String? username;
  final String? smallProfilePictureUrl;
  final String? largeProfilePictureUrl;
  final String? bio;
  final String? location;
  final String? website;
  final DateTime? birthday;

  U({required this.uid, this.name, this.username, this.smallProfilePictureUrl, this.largeProfilePictureUrl, this.bio, this.location, this.website, this.birthday});

  @override
  String toString() {
    return 'User $uid';
  }

  static fromJson(Map<String, dynamic> json) {
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
    );
  }
}