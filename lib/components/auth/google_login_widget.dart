import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:tagify/components/auth/oauth_button.dart';
import 'package:tagify/api/user.dart';
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

      // Google OAuth로부터 액세스 토큰 가져오기
      final GoogleSignInAuthentication auth = await user.authentication;

      ApiResponse<Map<String, dynamic>> loginResponse = await login(
          oauthProvider,
          auth.idToken!,
          user.displayName ?? "Unknown",
          user.id,
          user.email,
          user.photoUrl ?? "",
          context.deviceLocale.languageCode.toString());

      // TODO: 에러 처리
      if (loginResponse.errorMessage != null) {
        debugPrint("Login Error: ${loginResponse.errorMessage}");
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
