import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'package:tagify/api/common.dart';

Future<ApiResponse<List<Article>>> fetchArticlesLimited(
    int limit, int offset, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/articles/all?limit=$limit&offset=$offset";

  final response = await authenticatedRequest(
    (token) => get(Uri.parse(serverHost), headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    }),
    accessToken,
  );

  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    List<dynamic> jsonList = jsonDecode(responseBody)["articles"];
    List<Article> articles =
        jsonList.map((item) => Article.fromJson(item)).toList();
    return ApiResponse(
        data: articles, statusCode: response.statusCode, success: true);
  }
  return ApiResponse.empty();
}

Future<ApiResponse<int>> postArticle(int userId, String title, String body,
    String encodedContent, String accessToken) async {
  final String serverHost = "${dotenv.get("SERVER_HOST")}/api/articles/";

  final response = await authenticatedRequest(
    (token) => post(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "user_id": userId,
        "title": title,
        "body": body,
        "encoded_content": encodedContent,
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

Future<ApiResponse<int>> deleteArticle(
    int userId, int articleId, String accessToken) async {
  final String serverHost = "${dotenv.get("SERVER_HOST")}/api/articles/";

  final response = await authenticatedRequest(
    (token) => delete(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "user_id": userId,
        "article_id": articleId,
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

Future<ApiResponse<int>> downloadArticle(
    int userId, String newTagName, int articleId, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/articles/download/$articleId";

  final response = await authenticatedRequest(
    (token) => post(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "user_id": userId,
        "tagname": newTagName,
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
