import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/auth_screen.dart';

Future<ApiResponse<Map<String, dynamic>>> login(
    String provider,
    String idToken,
    String userName,
    String oauthId,
    String email,
    String profileImage,
    String lang) async {
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
      "lang": lang,
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
  final provider = Provider.of<TagifyProvider>(context, listen: false);

  await prefs.remove("access_token");
  await prefs.remove("refresh_token");
  await prefs.remove("loginResponse");
  await prefs.clear();

  provider.currentPage = "home";
  provider.currentTag = "all";

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const AuthScreen()),
    (route) => false,
  );
}

Future<ApiResponse<int>> deleteAccount(
    BuildContext context, String reason, String accessToken) async {
  final provider = Provider.of<TagifyProvider>(context, listen: false);
  final String serverHost = "${dotenv.get("SERVER_HOST")}/api/users/me/delete";

  final response = await authenticatedRequest(
    (token) => post(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"id": provider.loginResponse!["id"], "reason": reason}),
    ),
    accessToken,
  );

  switch (response.statusCode) {
    case 200:
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove("access_token");
      await prefs.remove("refresh_token");
      await prefs.remove("loginResponse");
      await prefs.clear();

      provider.currentPage = "home";
      provider.currentTag = "all";

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }

      return ApiResponse(
        data: jsonDecode(response.body)["id"],
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

Future<ApiResponse<int>> updatePremiumStatus(
    int userId, String accessToken) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/users/premium/$userId";

  final response = await authenticatedRequest(
    (token) => put(
      Uri.parse(serverHost),
      headers: {
        "Authorization": "Bearer $token",
      },
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
