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
        errorMessage: e.toString(), statusCode: 500, success: false);
  }
}

Future<ApiResponse<Map<String, dynamic>>> analyzeContent(
    int userId, String url, String lang, String contentType) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/analyze?content_type=$contentType";

  try {
    final response = await ApiClient.dio.post(
      serverHost,
      data: {
        "user_id": userId,
        "url": url,
        "lang": lang,
      },
    );

    if (response.statusCode == 200) {
      return ApiResponse(
          data: response.data, statusCode: response.statusCode!, success: true);
    } else if (response.statusCode == 400) {
      return ApiResponse(
          errorMessage: "Content already exists",
          statusCode: response.statusCode!,
          success: false);
    } else {
      return ApiResponse(
          errorMessage: "failure",
          statusCode: response.statusCode!,
          success: false);
    }
  } catch (e) {
    return ApiResponse(
        errorMessage: e.toString(), statusCode: 500, success: false);
  }
}

// TODO : 정리
Future<ApiResponse<int>> saveContent(
  int userId,
  String url,
  String title,
  String thumbnail,
  String favicon,
  String description,
  bool bookmark,
  int length,
  String body,
  List<dynamic> tags,
  String contentType,
) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/save?content_type=$contentType";

  try {
    final response = await ApiClient.dio.post(
      serverHost,
      data: {
        "user_id": userId,
        "url": url,
        "title": title,
        "thumbnail": thumbnail,
        "favicon": favicon,
        "description": description,
        "bookmark": bookmark,
        "video_length": length,
        "body": body,
        "tags": tags,
      },
    );

    if (response.statusCode == 200) {
      return ApiResponse(
          data: response.data["id"],
          statusCode: response.statusCode!,
          success: true);
    }
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode!,
        success: false);
  } catch (e) {
    return ApiResponse(
        errorMessage: e.toString(), statusCode: 500, success: false);
  }
}

Future<ApiResponse<List<Video>>> fetchUserVideos(int userId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/user/sub&content_type=video&user_id=$userId";

  try {
    final response = await ApiClient.dio.get(serverHost);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = response.data;
      List<Video> videos =
          jsonList.map((item) => Video.fromJson(item)).toList();

      return ApiResponse(
          data: videos, statusCode: response.statusCode!, success: true);
    }
    return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode!,
        success: false);
  } catch (e) {
    return ApiResponse(
        errorMessage: e.toString(), statusCode: 500, success: false);
  }
}

// Future<ApiResponse<List<Post>>> fetchUserPosts(int userId) async {
// TODO
// }

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
        errorMessage: e.toString(), statusCode: 500, success: false);
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
        errorMessage: e.toString(), statusCode: 500, success: false);
  }
}

Future<ApiResponse<int>> deleteContent(int contentId) async {
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
        errorMessage: e.toString(), statusCode: 500, success: false);
  }
}
