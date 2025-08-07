class MusicAttachment {
  final String title;
  final String artist;
  final String artworkUrl;
  final String previewUrl;

  MusicAttachment({
    required this.title,
    required this.artist,
    required this.artworkUrl,
    required this.previewUrl,
  });

  factory MusicAttachment.fromJson(Map<String, dynamic> json) {
    return MusicAttachment(
      title: json['trackName'] ?? '',
      artist: json['artistName'] ?? '',
      artworkUrl: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackName': title,
      'artistName': artist,
      'artworkUrl100': artworkUrl,
      'previewUrl': previewUrl,
    };
  }

  Map<String, dynamic> toCache() => toJson();

  factory MusicAttachment.fromCache(Map<String, dynamic> json) =>
      MusicAttachment.fromJson(json);
}
