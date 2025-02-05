import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

Future<dynamic> login(String id, String email) async {
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
    return jsonDecode(response.body);
  } else if (response.statusCode == 400) {
    // 회원 존재하지 않음
    return {
      "status": "failure",
      "code": response.statusCode,
    };
  } else {
    return {
      "status": "error",
      "code": response.statusCode,
    };
  }
}

Future<dynamic> signup(Map<String, dynamic> userInfo) async {
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
    return jsonDecode(response.body);
  } else if (response.statusCode == 400) {
    // 이미 존재하는 회원
    return {
      "status": "failure",
      "code": response.statusCode,
    };
  } else {
    return {
      "status": "error",
      "code": response.statusCode,
    };
  }
}
