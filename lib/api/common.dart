import 'dart:ui';

class ApiResponse<T> {
  final T? data;
  final String? errorMessage;
  final bool success;
  final int statusCode;

  ApiResponse(
      {this.data,
      this.errorMessage,
      required this.success,
      required this.statusCode});

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'message': errorMessage,
      'success': success,
      'statusCode': statusCode,
    };
  }

  factory ApiResponse.empty() {
    return ApiResponse(success: false, statusCode: 200);
  }
}

class Tag {
  final String tagName;
  final int id;
  final Color color;

  const Tag({
    required this.tagName,
    required this.id,
    required this.color,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json["tag_id"],
      tagName: json["tag"],
      color: Color(json["color"]),
    );
  }
}

class Article {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String encodedContent;
  final int upCount;
  final int downCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Article({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.encodedContent,
    required this.upCount,
    required this.downCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      body: json['body'],
      encodedContent: json['encoded_content'],
      upCount: json['up_count'],
      downCount: json['down_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'encoded_content': encodedContent,
      'up_count': upCount,
      'down_count': downCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
