import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/dio.dart';

Future<ApiResponse<List<Article>>> fetchArticlesLimited(
    int limit, int offset) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/articles/all?limit=$limit&offset=$offset";

  try {
    final response = await ApiClient.dio.get(serverHost);

    if (response.statusCode! == 200) {
      List<dynamic> jsonList = response.data["articles"];
      List<Article> articles =
          jsonList.map((item) => Article.fromJson(item)).toList();

      return ApiResponse(
          data: articles, statusCode: response.statusCode!, success: true);
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

Future<ApiResponse<int>> postArticle(
    int userId, String title, String body, String encodedContent) async {
  final String serverHost = "${dotenv.get("SERVER_HOST")}/api/articles/";

  try {
    final response = await ApiClient.dio.post(serverHost, data: {
      "user_id": userId,
      "title": title,
      "body": body,
      "encoded_content": encodedContent,
    });

    if (response.statusCode! == 200) {
      return ApiResponse(
          data: response.data, statusCode: response.statusCode!, success: true);
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

Future<ApiResponse<int>> deleteArticle(int userId, int articleId) async {
  final String serverHost = "${dotenv.get("SERVER_HOST")}/api/articles/";

  try {
    final response = await ApiClient.dio.delete(serverHost, data: {
      "user_id": userId,
      "article_id": articleId,
    });

    if (response.statusCode! == 200) {
      return ApiResponse(
          data: response.data, statusCode: response.statusCode!, success: true);
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

Future<ApiResponse<int>> downloadArticle(
    int userId, String newTagName, int articleId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/articles/download/$articleId";

  try {
    final response = await ApiClient.dio.post(serverHost, data: {
      "user_id": userId,
      "tag_name": newTagName,
    });

    if (response.statusCode! == 200) {
      return ApiResponse(
          data: response.data, statusCode: response.statusCode!, success: true);
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
