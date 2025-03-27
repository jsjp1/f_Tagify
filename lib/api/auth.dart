import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> refreshToken() async {
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
    String newAccessToken = responseBody["access_token"];
    await prefs.setString("access_token", newAccessToken);

    // TODO: provider의 access token도 수정해야 함

    debugPrint("New Access token: $newAccessToken");
    return newAccessToken;
  } else {
    return null;
  }
}
