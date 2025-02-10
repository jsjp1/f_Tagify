import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'package:tagify/api/common.dart';

Future<ApiResponse<Map<String, dynamic>>> login(String id, String email) async {
  final String serverHost = "${dotenv.get("SERVER_HOST")}/api/users/login";
  late final Response response;

  response = await post(
    Uri.parse(serverHost),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "oauth_id": id,
      "email": email,
    }),
  );

  if (response.statusCode == 200) {
    return ApiResponse(
      data: jsonDecode(response.body),
      statusCode: response.statusCode,
      success: true,
    );
  } else if (response.statusCode == 400) {
    // 이미 존재하는 회원
    return ApiResponse(
      errorMessage: "failure",
      statusCode: response.statusCode,
      success: false,
    );
  } else {
    return ApiResponse(
        errorMessage: "error", statusCode: response.statusCode, success: false);
  }
}

Future<ApiResponse<Map<String, dynamic>>> signup(
    Map<String, dynamic> userInfo) async {
  final String serverHost = "${dotenv.get("SERVER_HOST")}/api/users/signup";
  late final Response response;

  response = await post(
    Uri.parse(serverHost),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(userInfo),
  );

  if (response.statusCode == 200) {
    return ApiResponse(
      data: jsonDecode(response.body),
      statusCode: response.statusCode,
      success: true,
    );
  } else if (response.statusCode == 400) {
    // 이미 존재하는 회원
    return ApiResponse(
      errorMessage: "failure",
      statusCode: response.statusCode,
      success: false,
    );
  } else {
    return ApiResponse(
        errorMessage: "error", statusCode: response.statusCode, success: false);
  }
}
