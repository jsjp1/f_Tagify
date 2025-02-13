class Content {
  final String url;
  final String title;
  final String thumbnail;
  final List<String> tags;

  const Content(
      {required this.url,
      required this.title,
      required this.thumbnail,
      required this.tags});
}

class Video extends Content {
  final int length;

  Video(
      {required this.length,
      required super.url,
      required super.title,
      required super.thumbnail,
      required super.tags});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      url: json["url"] ?? "",
      title: json["title"],
      length: json["video_length"],
      thumbnail: json["thumbnail"],
      tags: List<String>.from(json["tags"] ?? []),
    );
  }
}

class Post extends Content {
  final String body;

  Post(
      {required this.body,
      required super.url,
      required super.title,
      required super.thumbnail,
      required super.tags});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      url: json["url"] ?? "",
      title: json["title"],
      body: json["video_length"],
      thumbnail: json["thumbnail"],
      tags: List<String>.from(json["tags"] ?? []),
    );
  }
}
