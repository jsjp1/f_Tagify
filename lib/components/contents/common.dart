class Content {
  final int id;
  final String url;
  String title;
  final String thumbnail;
  final String favicon;
  String description;
  bool bookmark;
  List<dynamic> tags;
  final String type;

  Content(
      {required this.id,
      required this.url,
      required this.title,
      required this.thumbnail,
      required this.favicon,
      required this.description,
      required this.bookmark,
      required this.tags,
      required this.type});

  factory Content.empty() {
    return Content(
      id: -1,
      url: "",
      title: "",
      thumbnail: "",
      favicon: "",
      description: "",
      bookmark: false,
      tags: [],
      type: "post",
    );
  }

  factory Content.fromJson(Map<String, dynamic> json) {
    String contentType = json["type"].toString();
    switch (json["type"]) {
      case "video":
        return Video.fromJson(json);
      case "post":
        return Post.fromJson(json);
      default:
        return Content(
          id: json["id"],
          url: json["url"],
          title: json["title"],
          thumbnail: json["thumbnail"],
          favicon: json["favicon"],
          description: json["description"],
          bookmark: json["bookmark"],
          tags: json["tags"],
          type: contentType,
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "url": url,
      "title": title,
      "thumbnail": thumbnail,
      "favicon": favicon,
      "description": description,
      "bookmark": bookmark,
      "tags": tags,
      "type": type,
    };
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
      required super.favicon,
      required super.description,
      required super.bookmark,
      required super.tags,
      required super.type});

  factory Video.fromJson(Map<String, dynamic> json) {
    String contentType = json["type"].toString();
    return Video(
      id: json["id"],
      url: json["url"],
      title: json["title"],
      length: json["video_length"] ?? 0,
      thumbnail: json["thumbnail"],
      favicon: json["favicon"],
      description: json["description"],
      bookmark: json["bookmark"],
      tags: json["tags"],
      type: contentType,
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
      required super.favicon,
      required super.description,
      required super.bookmark,
      required super.tags,
      required super.type});

  factory Post.fromJson(Map<String, dynamic> json) {
    String contentType = json["type"].toString();
    return Post(
      id: json["id"],
      url: json["url"],
      title: json["title"],
      body: json["body"] ?? "",
      thumbnail: json["thumbnail"],
      favicon: json["favicon"],
      description: json["description"],
      bookmark: json["bookmark"],
      tags: json["tags"],
      type: contentType,
    );
  }
}
