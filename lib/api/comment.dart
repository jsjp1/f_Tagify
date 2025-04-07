import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'package:tagify/api/common.dart';

Future<ApiResponse<List<Comment>>> fetchArticleAllComments(
    int articleId, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/comments/article/$articleId";

  final response = await authenticatedRequest(
    (token) => get(Uri.parse(serverHost), headers: {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    }),
    accessToken,
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> responseMap =
        jsonDecode(utf8.decode(response.bodyBytes));
    List<dynamic> jsonList = responseMap["comments"];
    return ApiResponse(
      data: jsonList.map((item) => Comment.fromJson(item)).toList(),
      statusCode: response.statusCode,
      success: true,
    );
  }
  return ApiResponse.empty();
}

Future<ApiResponse<int>> postArticleComment(
    int userId, int articleId, String body, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/comments/article/$articleId";

  final response = await authenticatedRequest(
    (token) => post(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "user_id": userId,
        "body": body,
      }),
    ),
    accessToken,
  );

  if (response.statusCode == 200) {
    return ApiResponse(
      data: jsonDecode(response.body)["id"],
      statusCode: response.statusCode,
      success: true,
    );
  }
  return ApiResponse.empty();
}

Future<ApiResponse<int>> deleteArticleComment(
    int commentId, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/comments/$commentId";

  final response = await authenticatedRequest(
    (token) => delete(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    ),
    accessToken,
  );

  if (response.statusCode == 200) {
    return ApiResponse(
      data: jsonDecode(response.body)["id"],
      statusCode: response.statusCode,
      success: true,
    );
  }
  return ApiResponse.empty();
}
