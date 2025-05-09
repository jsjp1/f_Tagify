import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>?> refreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? refreshToken = prefs.getString("refresh_token");
  if (refreshToken == null) return null;

  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/users/token/refresh";

  final response = await post(
    Uri.parse(serverHost),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "refresh_token": refreshToken,
    }),
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> responseBody = jsonDecode(response.body);
    Map<String, dynamic> tokens = responseBody["tokens"];

    String newAccessToken = tokens["access_token"];
    String newRefreshToken = tokens["refresh_token"];

    await prefs.setString("access_token", newAccessToken);
    await prefs.setString("refresh_token", newRefreshToken);

    // TODO: provider의 access token도 수정해야 함
    debugPrint("New Access token: $newAccessToken");
    debugPrint("New Refresh token: $newRefreshToken");
    return [newAccessToken, newRefreshToken];
  } else {
    return null;
  }
}

Future<bool> checkRefreshToken(String refreshToken) async {
  // refresh token 만료기간 지났는지 확인 후, 지난 경우 false, 아직 지나지 않은 경우 true
  final String serverHost =
      "${dotenv.get("SERVER_HOST")}/api/users/token/check/refresh_token";

  final response = await post(
    Uri.parse(serverHost),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "refresh_token": refreshToken,
    }),
  );

  bool isValid = false;

  if (response.statusCode == 200) {
    Map<String, dynamic> responseBody = jsonDecode(response.body);
    isValid = responseBody["valid"];
  }

  return isValid;
}
