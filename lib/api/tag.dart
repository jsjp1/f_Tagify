import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';

Future<ApiResponse<List<Tag>>> fetchUserTags(
    int userId, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/tags/user/$userId";

  final response = await authenticatedRequest(
    (token) => get(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    ),
    accessToken,
  );

  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = jsonDecode(responseBody);
    List<Tag> tags = jsonList.map((item) => Tag.fromJson(item)).toList();

    return ApiResponse(
        data: tags, statusCode: response.statusCode, success: true);
  }
  return ApiResponse.empty();
}

Future<ApiResponse<List<Content>>> fetchUserTagAllContents(
    int tagId, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/tags/$tagId/contents/all";

  final response = await authenticatedRequest(
    (token) => get(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    ),
    accessToken,
  );

  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = jsonDecode(responseBody);
    List<Content> contents =
        jsonList.map((item) => Content.fromJson(item)).toList();

    return ApiResponse(
        data: contents, statusCode: response.statusCode, success: true);
  }
  return ApiResponse.empty();
}

Future<ApiResponse<Tag>> postTag(
    int userId, String tagName, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/tags/user/$userId/create";

  final response = await authenticatedRequest(
    (token) => post(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode({"id": userId, "tagname": tagName}),
    ),
    accessToken,
  );

  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    Tag tag = Tag.fromJson(jsonDecode(responseBody));

    return ApiResponse(
        data: tag, statusCode: response.statusCode, success: true);
  }
  return ApiResponse.empty();
}

Future<ApiResponse<int>> updateTag(int userId, int tagId, String tagName,
    Color tagColor, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/tags/user/$userId/$tagId/update";

  final response = await authenticatedRequest(
    (token) => put(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "tagname": tagName,
        "color": tagColor.value,
      }),
    ),
    accessToken,
  );

  if (response.statusCode == 200) {
    return ApiResponse(
        data: jsonDecode(response.body)["id"],
        statusCode: response.statusCode,
        success: true);
  }
  return ApiResponse.empty();
}

Future<ApiResponse<int>> deleteTag(
    int userId, int tagId, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/tags/user/$userId/delete";

  final response = await authenticatedRequest(
    (token) => delete(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"id": tagId}),
    ),
    accessToken,
  );

  if (response.statusCode == 200) {
    return ApiResponse(
        data: jsonDecode(response.body)["id"],
        statusCode: response.statusCode,
        success: true);
  }
  return ApiResponse.empty();
}
