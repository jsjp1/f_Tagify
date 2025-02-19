import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/dio.dart';
import 'package:tagify/components/contents/common.dart';

String? authToken;

Future<void> loadAuthToken(String token) async {
  authToken = token;
}

Future<ApiResponse<List<Content>>> fetchUserContents(int userId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/user/all?user_id=$userId";

  try {
    final response = await ApiClient.dio.get(serverHost);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = response.data;
      List<Content> contents =
          jsonList.map((item) => Content.fromJson(item)).toList();

      return ApiResponse(
          data: contents, statusCode: response.statusCode!, success: true);
    }
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode!,
        success: false);
  } catch (e) {
    return ApiResponse(
        errorMessage: "network_error", statusCode: 500, success: false);
  }
}

Future<ApiResponse<void>> analyzeVideo(
    String oauthId, String videoUrl, String lang) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/analyze?content_type=video";

  try {
    final response = await ApiClient.dio.post(
      serverHost,
      data: {
        "oauth_id": oauthId,
        "url": videoUrl,
        "lang": lang,
      },
    );

    if (response.statusCode == 200) {
      return ApiResponse(
          data: response.data["video_id"],
          statusCode: response.statusCode!,
          success: true);
    }
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode!,
        success: false);
  } catch (e) {
    return ApiResponse(
        errorMessage: "network_error", statusCode: 500, success: false);
  }
}

Future<ApiResponse<List<Content>>> fetchUserVideos(int userId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/user/sub&content_type=video&user_id=$userId";

  try {
    final response = await ApiClient.dio.get(serverHost);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = response.data;
      List<Content> contents =
          jsonList.map((item) => Content.fromJson(item)).toList();

      return ApiResponse(
          data: contents, statusCode: response.statusCode!, success: true);
    }
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode!,
        success: false);
  } catch (e) {
    return ApiResponse(
        errorMessage: "network_error", statusCode: 500, success: false);
  }
}

Future<ApiResponse<int>> toggleBookmark(int contentId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/$contentId/bookmark";

  try {
    final response = await ApiClient.dio.post(serverHost);

    if (response.statusCode == 200) {
      return ApiResponse(
          data: response.data["content_id"],
          statusCode: response.statusCode!,
          success: true);
    }
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode!,
        success: false);
  } catch (e) {
    return ApiResponse(
        errorMessage: "network_error", statusCode: 500, success: false);
  }
}

Future<ApiResponse<List<Content>>> fetchBookmarkContents(int userId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/bookmarks/user/$userId";

  try {
    final response = await ApiClient.dio.get(serverHost);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = response.data;
      List<Content> contents =
          jsonList.map((item) => Content.fromJson(item)).toList();

      return ApiResponse(
          data: contents, statusCode: response.statusCode!, success: true);
    }
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode!,
        success: false);
  } catch (e) {
    return ApiResponse(
        errorMessage: "network_error", statusCode: 500, success: false);
  }
}

Future<ApiResponse<void>> deleteContent(int contentId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/$contentId";

  try {
    final response = await ApiClient.dio.delete(serverHost);

    if (response.statusCode == 200) {
      return ApiResponse(
          data: response.data["content_id"],
          statusCode: response.statusCode!,
          success: true);
    }
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode!,
        success: false);
  } catch (e) {
    return ApiResponse(
        errorMessage: "network_error", statusCode: 500, success: false);
  }
}
