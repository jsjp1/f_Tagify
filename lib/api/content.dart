import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';

Future<ApiResponse<List<Video>>> fetchUserVideos(String oauthId) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/user?content_type=video&oauth_id=$oauthId";
  late final Response response;

  response = await get(
    Uri.parse(serverHost),
    headers: {
      "Content-Type": "application/json",
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

Future<ApiResponse<void>> analyzeVideo(
    String oauthId, String videoUrl, String lang) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/contents/analyze?content_type=video";
  late final Response response;

  response = await post(
    Uri.parse(serverHost),
    headers: {
      "Content-Type": "application/json",
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
