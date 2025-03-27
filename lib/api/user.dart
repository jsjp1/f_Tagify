import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/screens/auth_screen.dart';

Future<ApiResponse<Map<String, dynamic>>> login(String provider, String idToken,
    String userName, String oauthId, String email, String profileImage) async {
  final String providerLower = provider.toLowerCase();
  final String serverHost = "${dotenv.get("SERVER_HOST")}/api/users/login";

  final response = await post(
    Uri.parse(serverHost),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: jsonEncode({
      "id_token": idToken,
      "username": userName,
      "oauth_provider": providerLower,
      "oauth_id": oauthId,
      "email": email,
      "profile_image": profileImage,
    }),
  );

  switch (response.statusCode) {
    case 200:
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> responseData = jsonDecode(responseBody);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", responseData["access_token"] ?? "");
      await prefs.setString(
          "refresh_token", responseData["refresh_token"] ?? "");

      return ApiResponse(
        data: responseData,
        statusCode: response.statusCode,
        success: true,
      );
    default:
      return ApiResponse(
        statusCode: response.statusCode,
        success: false,
        errorMessage: response.body,
      );
  }
}

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove("access_token");
  await prefs.remove("refresh_token");
  await prefs.remove("loginResponse");
  await prefs.clear();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const AuthScreen()),
    (route) => false,
  );
}

Future<ApiResponse<int>> updateUserName(
    int userId, String newName, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/users/name/$userId";

  final response = await authenticatedRequest(
    (token) => put(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": newName,
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
