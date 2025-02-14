class Content {
  final int id;
  final String url;
  final String title;
  final String thumbnail;
  final String description;
  final bool bookmark;
  final List<String> tags;

  const Content(
      {required this.id,
      required this.url,
      required this.title,
      required this.thumbnail,
      required this.description,
      required this.bookmark,
      required this.tags});

  factory Content.fromJson(Map<String, dynamic> json) {
    switch (json['content_type']) {
      case 'video':
        return Video.fromJson(json);
      case 'post':
        return Post.fromJson(json);
      default:
        return Content(
          id: json["id"],
          url: json["url"],
          title: json["title"],
          thumbnail: json["thumbnail"] ?? '',
          description: json["description"],
          bookmark: json["bookmark"],
          tags: List<String>.from(json["tags"] ?? []),
        );
    }
  }
}

class Video extends Content {
  final int length;

  Video(
      {required this.length,
      required super.id,
      required super.url,
      required super.title,
      required super.thumbnail,
      required super.description,
      required super.bookmark,
      required super.tags});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json["id"],
      url: json["url"] ?? "",
      title: json["title"],
      length: json["video_length"] ?? 0,
      thumbnail: json["thumbnail"] ?? "",
      description: json["description"],
      bookmark: json["bookmark"],
      tags: List<String>.from(json["tags"] ?? []),
    );
  }
}

class Post extends Content {
  final String body;

  Post(
      {required this.body,
      required super.id,
      required super.url,
      required super.title,
      required super.thumbnail,
      required super.description,
      required super.bookmark,
      required super.tags});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      url: json["url"],
      title: json["title"],
      body: json["video_length"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      description: json["description"] ?? "",
      bookmark: json["bookmark"],
      tags: List<String>.from(json["tags"] ?? []),
    );
  }
}
