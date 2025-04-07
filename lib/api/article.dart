import 'dart:convert';

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

Future<ApiResponse<List<Article>>> fetchUserArticlesLimited(
    int userId, int limit, int offset, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/articles/user/$userId?limit=$limit&offset=$offset";

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
    String encodedContent, List<String> tags, String accessToken) async {
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
        "tags": tags,
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

Future<ApiResponse<int>> putArticle(int userId, int articleId, String title,
    String body, List<String> tags, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/articles/$articleId";

  final response = await authenticatedRequest(
    (token) => put(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "title": title,
        "body": body,
        "tags": tags,
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
        data: jsonDecode(response.body)["tag_id"],
        statusCode: response.statusCode,
        success: true);
  }
  return ApiResponse.empty();
}

Future<ApiResponse<List<Article>>> fetchCategoryArticles(
    int limit, int offset, String category, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/articles/$category?limit=$limit&offset=$offset";

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

Future<ApiResponse<List<Map<String, dynamic>>>> fetchCategoryTags(
    int count, String category, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/articles/tags/$category/$count";

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
    Map<String, dynamic> responseMap = jsonDecode(responseBody);

    if (responseMap.containsKey("tags") && responseMap["tags"] is List) {
      List<Map<String, dynamic>> tags = (responseMap["tags"] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      if (tags.length >= count) {
        tags = tags.sublist(0, count);
      }

      return ApiResponse(
          data: tags, statusCode: response.statusCode, success: true);
    }
  }
  return ApiResponse.empty();
}

Future<ApiResponse<List<Map<String, dynamic>>>> fetchOwnedTags(
    int count, int userId, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/articles/tags/owned/$userId/$count";

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
    Map<String, dynamic> responseMap = jsonDecode(responseBody);

    if (responseMap.containsKey("tags") && responseMap["tags"] is List) {
      List<Map<String, dynamic>> tags = (responseMap["tags"] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      if (count != -1 && tags.length >= count) {
        tags = tags.sublist(0, count);
      }

      return ApiResponse(
          data: tags, statusCode: response.statusCode, success: true);
    }
  }
  return ApiResponse.empty();
}

Future<ApiResponse<List<Article>>> fetchTaggedArticlesLimited(
    int tagId, int limit, int offset, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/articles/tag/$tagId?limit=$limit&offset=$offset";

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
