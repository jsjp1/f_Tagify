import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/api/dio.dart';

Future<ApiResponse<Map<String, dynamic>>> login(String provider, String idToken,
    String userName, String oauthId, String email, String profileImage) async {
  final String providerLower = provider.toLowerCase();
  final String serverHost = "${dotenv.get("SERVER_HOST")}/api/users/login";
  late final Response response;

  try {
    response = await ApiClient.dio.post(
      serverHost,
      data: jsonEncode({
        "id_token": idToken,
        "username": userName,
        "oauth_provider": providerLower,
        "oauth_id": oauthId,
        "email": email,
        "profile_image": profileImage,
      }),
    );

    if (response.statusCode! == 200) {
      final data = response.data as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", data["access_token"] ?? "");
      await prefs.setString("refresh_token", data["refresh_token"] ?? "");

      return ApiResponse(
        data: data,
        statusCode: response.statusCode!,
        success: true,
      );
    } else if (response.statusCode! == 400) {
      return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode!,
        success: false,
      );
    } else {
      return ApiResponse(
        errorMessage: "error",
        statusCode: response.statusCode!,
        success: false,
      );
    }
  } catch (e) {
    return ApiResponse(
      errorMessage: e.toString(),
      statusCode: 500,
      success: false,
    );
  }
}

Future<ApiResponse<Map<String, dynamic>>> signup(
    Map<String, dynamic> userInfo) async {
  final String serverHost = "${dotenv.get("SERVER_HOST")}/api/users/signup";
  late final Response response;

  try {
    response = await ApiClient.dio.post(
      serverHost,
      data: jsonEncode(userInfo),
    );

    if (response.statusCode! == 200) {
      final data = response.data as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access_token", data["access_token"] ?? "");
      await prefs.setString("refresh_token", data["refresh_token"] ?? "");

      return ApiResponse(
        data: data,
        statusCode: response.statusCode!,
        success: true,
      );
    } else if (response.statusCode == 400) {
      return ApiResponse(
        errorMessage: "failure",
        statusCode: response.statusCode!,
        success: false,
      );
    } else {
      return ApiResponse(
        errorMessage: "error",
        statusCode: response.statusCode!,
        success: false,
      );
    }
  } catch (e) {
    return ApiResponse(
      errorMessage: e.toString(),
      statusCode: 500,
      success: false,
    );
  }
}

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("access_token");
  await prefs.remove("refresh_token");

  Navigator.pushNamedAndRemoveUntil(
    context,
    "/auth",
    (route) => false,
  );
}

Future<ApiResponse<int>> updateUserName(int userId, String newName) async {
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/users/name/$userId";

  try {
    final response = await ApiClient.dio.put(serverHost, data: {
      "username": newName,
    });

    if (response.statusCode! == 200) {
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
