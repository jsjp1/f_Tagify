import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';

Future<ApiResponse<List<Content>>> fetchUserContents(
    int userId, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/user/$userId/all";

  final response = await authenticatedRequest(
    (token) => get(Uri.parse(serverHost), headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    }),
    accessToken,
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
    return ApiResponse(
      data: jsonList.map((item) => Content.fromJson(item)).toList(),
      statusCode: response.statusCode,
      success: true,
    );
  }
  return ApiResponse.empty();
}

Future<ApiResponse<Content>> analyzeContent(int userId, String url, String lang,
    String contentType, String accessToken) async {
  final String endpoint =
      "${dotenv.get("SERVER_HOST")}/api/contents/analyze?content_type=$contentType";

  final response = await authenticatedRequest(
    (token) => post(
      Uri.parse(endpoint),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "user_id": userId,
        "url": url,
        "lang": lang,
      }),
    ),
    accessToken,
  );

  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonData = jsonDecode(responseBody);
    jsonData["id"] = -1; // 임시 id 배정후, saveContent시 변경
    jsonData["bookmark"] = false;
    jsonData["type"] = contentType;
    Content content = Content.fromJson(jsonData);
    return ApiResponse(
      data: content,
      statusCode: response.statusCode,
      success: true,
    );
  } else if (response.statusCode == 400) {
    return ApiResponse(
      statusCode: response.statusCode,
      errorMessage: jsonDecode(response.body)["detail"],
      success: false,
    );
  } else if (response.statusCode == 404 || response.statusCode == 422) {
    // analyze가 불가능한, 잘못된 url
    return ApiResponse(
      statusCode: response.statusCode,
      errorMessage: jsonDecode(response.body)["detail"],
      success: false,
    );
  }

  return ApiResponse.empty();
}

Future<ApiResponse<Map<String, dynamic>>> saveContent(
  Content content,
  int userId,
  String accessToken,
) async {
  final String endpoint =
      "${dotenv.get("SERVER_HOST")}/api/contents/save?content_type=${content.type}";

  final response = await authenticatedRequest(
    (token) => post(
      Uri.parse(endpoint),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "user_id": userId,
        "url": content.url,
        "title": content.title,
        "thumbnail": content.thumbnail,
        "favicon": content.favicon,
        "description": content.description,
        "bookmark": content.bookmark,
        "video_length": 0,
        "body": "",
        "tags": content.tags,
      }),
    ),
    accessToken,
  );

  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    final data = jsonDecode(responseBody);
    List<Tag> tags =
        List<Tag>.from(data["tags"].map((tag) => Tag.fromJson(tag)));

    return ApiResponse(
      data: {
        "id": data["id"],
        "tags": tags,
      },
      statusCode: response.statusCode,
      success: true,
    );
  }
  return ApiResponse.empty();
}

Future<ApiResponse<Map<String, dynamic>>> editContent(
  Content content,
  int contentId,
  int userId,
  String accessToken,
) async {
  final String endpoint =
      "${dotenv.get("SERVER_HOST")}/api/contents/$contentId/user/$userId";

  final response = await authenticatedRequest(
    (token) => put(
      Uri.parse(endpoint),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "user_id": userId,
        "url": content.url,
        "title": content.title,
        "thumbnail": content.thumbnail,
        "favicon": content.favicon,
        "description": content.description,
        "bookmark": content.bookmark,
        "video_length": 0,
        "body": "",
        "tags": content.tags,
      }),
    ),
    accessToken,
  );

  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonData = jsonDecode(responseBody);

    return ApiResponse(
      data: jsonData,
      statusCode: response.statusCode,
      success: true,
    );
  }
  return ApiResponse.empty();
}

Future<ApiResponse<List<Video>>> fetchUserVideos(
    int userId, String accessToken) async {
  final String url =
      "${dotenv.get("SERVER_HOST")}/api/contents/user/$userId/sub?content_type=video";

  final response = await authenticatedRequest(
    (token) => get(Uri.parse(url), headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    }),
    accessToken,
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonList = jsonDecode(response.body);
    return ApiResponse(
      data: jsonList.map((item) => Video.fromJson(item)).toList(),
      statusCode: response.statusCode,
      success: true,
    );
  }
  return ApiResponse.empty();
}

Future<ApiResponse<int>> toggleBookmark(
    int contentId, String accessToken) async {
  final String url =
      "${dotenv.get("SERVER_HOST")}/api/contents/$contentId/bookmark";

  final response = await authenticatedRequest(
    (token) => post(Uri.parse(url), headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    }),
    accessToken,
  );

  if (response.statusCode == 200) {
    return ApiResponse(
      data: jsonDecode(response.body)["content_id"],
      statusCode: response.statusCode,
      success: true,
    );
  }
  return ApiResponse.empty();
}

Future<ApiResponse<List<Content>>> fetchBookmarkContents(
    int userId, String accessToken) async {
  final String url =
      "${dotenv.get("SERVER_HOST")}/api/contents/bookmarks/user/$userId";

  final response = await authenticatedRequest(
    (token) => get(Uri.parse(url), headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    }),
    accessToken,
  );

  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = jsonDecode(responseBody);
    return ApiResponse(
      data: jsonList.map((item) => Content.fromJson(item)).toList(),
      statusCode: response.statusCode,
      success: true,
    );
  }
  return ApiResponse.empty();
}

Future<ApiResponse<int>> deleteContent(
    int contentId, String accessToken) async {
  final String url = "${dotenv.get("SERVER_HOST")}/api/contents/$contentId";

  final response = await authenticatedRequest(
    (token) => delete(Uri.parse(url), headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    }),
    accessToken,
  );

  if (response.statusCode == 200) {
    return ApiResponse(
      data: jsonDecode(response.body)["content_id"],
      statusCode: response.statusCode,
      success: true,
    );
  }
  return ApiResponse.empty();
}

Future<ApiResponse<List<Content>>> searchContents(
    int userId, String keyword, String accessToken) async {
  final String url =
      "${dotenv.get("SERVER_HOST")}/api/contents/user/$userId/search/$keyword";

  final response = await authenticatedRequest(
    (token) => get(Uri.parse(url), headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json"
    }),
    accessToken,
  );

  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> responseMap = jsonDecode(responseBody);
    List<dynamic> jsonList = responseMap["contents"];
    return ApiResponse(
      data: jsonList.map((item) => Content.fromJson(item)).toList(),
      statusCode: response.statusCode,
      success: true,
    );
  }
  return ApiResponse.empty();
}
