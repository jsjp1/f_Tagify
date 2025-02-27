import 'dart:ui';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/dio.dart';

Future<ApiResponse<List<Tag>>> fetchUserTags(int userId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/tags/user/$userId";

  try {
    final response = await ApiClient.dio.get(serverHost);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = response.data;
      List<Tag> tags = jsonList.map((item) => Tag.fromJson(item)).toList();

      return ApiResponse(
          data: tags, statusCode: response.statusCode!, success: true);
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

Future<ApiResponse<int>> postTag(int userId, String tagName) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/tags/user/$userId/create";

  try {
    final response = await ApiClient.dio.post(serverHost, data: {
      "tagname": tagName,
    });

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

Future<ApiResponse<int>> updateTag(
    int userId, int tagId, String tagName, Color tagColor) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/tags/user/$userId/$tagId/update";

  try {
    final response = await ApiClient.dio.put(serverHost, data: {
      "tagname": tagName,
      "color": tagColor.value,
    });

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

Future<ApiResponse<int>> deleteTag(int userId, String tagName) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/tags/user/$userId/delete";

  try {
    final response = await ApiClient.dio.delete(serverHost, data: {
      "tagname": tagName,
    });

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
