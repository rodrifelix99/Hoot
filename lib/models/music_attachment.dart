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
}
