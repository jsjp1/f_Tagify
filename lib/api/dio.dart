import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.get("SERVER_HOST"),
    headers: {"Content-Type": "application/json"},
  ));

  ApiClient._internal() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        String? accessToken = prefs.getString("access_token");

        if (accessToken != null) {
          options.headers["Authorization"] = "Bearer $accessToken";
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final newToken = await _refreshToken();

          if (newToken != null) {
            e.requestOptions.headers["Authorization"] = "Bearer $newToken";

            return handler.resolve(await _dio.fetch(e.requestOptions));
          }
        }
        return handler.next(e);
      },
    ));
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  static Dio get dio => _dio;

  static Future<String?> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString("refresh_token");
    final String serverHost =
        "${dotenv.get("SERVER_HOST")}/api/users/token/refresh";

    if (refreshToken == null) return null;

    try {
      final response = await Dio().post(
        serverHost,
        data: jsonEncode({"refresh_token": "Bearer $refreshToken"}),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        String newAccessToken = response.data["access_token"];
        await prefs.setString("access_token", newAccessToken);
        return newAccessToken;
      }
    } catch (e) {
      debugPrint("Refresh Token Failed: $e");
    }
    return null;
  }
}
