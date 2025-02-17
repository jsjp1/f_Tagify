import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:tagify/components/auth/oauth_button.dart';
import 'package:tagify/api/auth.dart';
import 'package:tagify/api/common.dart';

class GoogleLoginWidget extends StatefulWidget {
  const GoogleLoginWidget({super.key});

  @override
  State<GoogleLoginWidget> createState() => _GoogleLoginWidgetState();
}

class _GoogleLoginWidgetState extends State<GoogleLoginWidget> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS ? dotenv.get("GID_CLIENT_ID") : null,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) {});
    _googleSignIn.signInSilently();
  }

  Future<Map<String, dynamic>> _handleSignIn() async {
    try {
      const String oauthProvider = "Google";
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user == null) {
        debugPrint("Google Sign-In was cancelled.");
        return {};
      }

      ApiResponse<Map<String, dynamic>> loginResponse =
          await login(user.id, user.email);

      if (loginResponse.errorMessage == "failure") {
        // 회원이 존재하지 않는 경우, 회원가입 후 다시 로그인
        final ApiResponse<Map<String, dynamic>> signupResponse = await signup({
          "username": user.displayName ?? "Unknown",
          "oauth_provider": oauthProvider,
          "oauth_id": user.id,
          "email": user.email,
          "profile_image": user.photoUrl ?? "",
        });

        if (signupResponse.errorMessage == "error") {
          debugPrint("Signup failed: status_code ${signupResponse.statusCode}");
          return {};
        }

        loginResponse = await login(user.id, user.email);
      } else if (loginResponse.errorMessage == "error") {
        debugPrint("Login Error: status_code ${loginResponse.statusCode}");
        return {};
      }

      return loginResponse.data ?? {};
    } catch (e) {
      debugPrint("Error signing in: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AuthButton(
          logoImage: "assets/img/google_logo.png",
          loginDescription: "google_login_button",
          loginFunction: _handleSignIn,
          buttonbackgroundColor: Colors.white,
          fontColor: Colors.black,
        ),
      ],
    );
  }
}
