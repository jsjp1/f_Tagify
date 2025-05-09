import "dart:ui";

import "package:flutter/material.dart";
import "package:http/http.dart";

import "package:tagify/api/auth.dart";

Future<Response> authenticatedRequest(
    Future<Response> Function(String) requestFn, String accessToken) async {
  Response response = await requestFn(accessToken);
  if (response.statusCode == 401) {
    List<String>? tokens = await refreshToken();
    if (tokens != null) {
      String newAccessToken = tokens[0];

      return await requestFn(newAccessToken);
    }
  }
  return response;
}

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
      "data": data,
      "message": errorMessage,
      "success": success,
      "statusCode": statusCode,
    };
  }

  factory ApiResponse.empty() {
    return ApiResponse(success: false, statusCode: 400);
  }
}

class Tag {
  String tagName;
  final int id;
  Color color;

  Tag({
    required this.tagName,
    required this.id,
    required this.color,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Tag && other.id == id && other.tagName == tagName);
  }

  @override
  int get hashCode => id.hashCode ^ tagName.hashCode;

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json["id"],
      tagName: json["tagname"],
      color: json["color"] == null ? Colors.grey : Color(json["color"]),
    );
  }

  factory Tag.empty() {
    return Tag(
      color: Colors.grey,
      tagName: "",
      id: -1,
    );
  }
}

class Article {
  final int id;
  final int userId;
  final String userName;
  final String userProfileImage;
  final String title;
  final String body;
  final String encodedContent;
  final int upCount;
  final int downCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  const Article({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.title,
    required this.body,
    required this.encodedContent,
    required this.upCount,
    required this.downCount,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.empty() {
    return Article(
      id: -1,
      userId: -1,
      userName: "",
      userProfileImage: "",
      title: "",
      body: "",
      encodedContent: "",
      upCount: 0,
      downCount: 0,
      tags: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json["id"],
      userId: json["user_id"],
      userName: json["user_name"],
      userProfileImage: json["user_profile_image"],
      title: json["title"],
      body: json["body"],
      encodedContent: json["encoded_content"],
      upCount: json["up_count"],
      downCount: json["down_count"],
      tags: List<String>.from(json["tags"]),
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "user_name": userName,
      "user_profile_image": userProfileImage,
      "title": title,
      "body": body,
      "encoded_content": encodedContent,
      "up_count": upCount,
      "down_count": downCount,
      "tags": tags,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
  }
}

class Comment {
  final int id;
  final int userId;
  final String userName;
  final String userProfileImage;
  final String body;
  final int upCount;
  final int downCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.body,
    required this.upCount,
    required this.downCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.empty() {
    return Comment(
      id: -1,
      userId: -1,
      userName: "",
      userProfileImage: "",
      body: "",
      upCount: 0,
      downCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["id"],
      userId: json["user_id"],
      userName: json["user_name"],
      userProfileImage: json["user_profile_image"],
      body: json["body"],
      upCount: json["up_count"],
      downCount: json["down_count"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "user_name": userName,
      "user_profile_image": userProfileImage,
      "body": body,
      "up_count": upCount,
      "down_count": downCount,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
  }
}
