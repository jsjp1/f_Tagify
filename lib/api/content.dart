import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';

String? authToken;

Future<void> loadAuthToken(String token) async {
  debugPrint("$token");
  authToken = token;
}

Future<ApiResponse<List<Content>>> fetchUserContents(int userId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/user/all?user_id=$userId";
  late final Response response;

  response = await get(
    Uri.parse(serverHost),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${authToken!}",
    },
  );

  if (response.statusCode == 200) {
    final String utf8DecodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = jsonDecode(utf8DecodedBody);
    List<Content> contents = jsonList.map((item) {
      return Content.fromJson(item);
    }).toList();

    return ApiResponse(
        data: contents, statusCode: response.statusCode, success: true);
  } else if (response.statusCode == 400) {
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode,
        success: false);
  } else {
    return ApiResponse(
        errorMessage: "error", statusCode: response.statusCode, success: false);
  }
}

Future<ApiResponse<void>> analyzeVideo(
    String oauthId, String videoUrl, String lang) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/analyze?content_type=video";
  late final Response response;

  response = await post(
    Uri.parse(serverHost),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${authToken!}",
    },
    body: jsonEncode({
      "oauth_id": oauthId,
      "url": videoUrl,
      "lang": lang,
    }),
  );

  if (response.statusCode == 200) {
    dynamic json = jsonDecode(response.body);

    return ApiResponse(
        data: json["video_id"], statusCode: response.statusCode, success: true);
  } else if (response.statusCode == 400) {
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode,
        success: false);
  } else {
    return ApiResponse(
        errorMessage: "error", statusCode: response.statusCode, success: false);
  }
}

Future<ApiResponse<List<Content>>> fetchUserVideos(int userId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/user/sub&content_type=video&user_id=$userId";
  late final Response response;

  response = await get(
    Uri.parse(serverHost),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${authToken!}",
    },
  );

  if (response.statusCode == 200) {
    final String utf8DecodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = jsonDecode(utf8DecodedBody);
    List<Video> videos = jsonList.map((item) => Video.fromJson(item)).toList();

    return ApiResponse(
        data: videos, statusCode: response.statusCode, success: true);
  } else if (response.statusCode == 400) {
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode,
        success: false);
  } else {
    return ApiResponse(
        errorMessage: "error", statusCode: response.statusCode, success: false);
  }
}

Future<ApiResponse<List<Content>>> fetchUserPosts(int userId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/user/sub&content_type=post&oauth_id=$userId";
  late final Response response;

  response = await get(
    Uri.parse(serverHost),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${authToken!}",
    },
  );

  if (response.statusCode == 200) {
    final String utf8DecodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = jsonDecode(utf8DecodedBody);
    List<Video> posts = jsonList.map((item) => Video.fromJson(item)).toList();

    return ApiResponse(
        data: posts, statusCode: response.statusCode, success: true);
  } else if (response.statusCode == 400) {
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode,
        success: false);
  } else {
    return ApiResponse(
        errorMessage: "error", statusCode: response.statusCode, success: false);
  }
}

Future<ApiResponse<int>> toggleBookmark(int contentId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/$contentId/bookmark";
  late final Response response;

  response = await post(
    Uri.parse(serverHost),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${authToken!}",
    },
  );

  if (response.statusCode == 200) {
    dynamic json = jsonDecode(response.body);

    return ApiResponse(
        data: json["content_id"],
        statusCode: response.statusCode,
        success: true);
  } else if (response.statusCode == 400) {
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode,
        success: false);
  } else {
    return ApiResponse(
        errorMessage: "error", statusCode: response.statusCode, success: false);
  }
}

Future<ApiResponse<List<Content>>> fetchBookmarkContents(int userId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/bookmarks/user/$userId";
  late final Response response;

  response = await get(
    Uri.parse(serverHost),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${authToken!}",
    },
  );

  if (response.statusCode == 200) {
    final String utf8DecodedBody = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = jsonDecode(utf8DecodedBody);

    List<Content> contents = jsonList.map((item) {
      return Content.fromJson(item);
    }).toList();

    return ApiResponse(
        data: contents, statusCode: response.statusCode, success: true);
  } else if (response.statusCode == 400) {
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode,
        success: false);
  } else {
    return ApiResponse(
        errorMessage: "error", statusCode: response.statusCode, success: false);
  }
}
