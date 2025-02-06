import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:tagify/components/oauth_button.dart';
import 'package:tagify/screens/home_screen.dart';
import 'package:tagify/api/auth.dart';

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

  Future<dynamic> _handleSignIn() async {
    try {
      const String oauthProvider = "Google";
      final GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user != null) {
        dynamic loginResponse = await login(user.id, user.email);
        debugPrint("$loginResponse");

        if (loginResponse["status"] == "failure") {
          // 회원이 존재하지 않는 경우
          final signupResponse = await signup({
            "username": user.displayName,
            "oauth_provider": oauthProvider,
            "oauth_id": user.id,
            "email": user.email,
            "profile_image": user.photoUrl,
          });
          debugPrint("$signupResponse");
          if (signupResponse["status"] == "error") {
            debugPrint("failure status_code: ${signupResponse["code"]}");
            return;
          }

          loginResponse = await login(user.id, user.email);
          debugPrint("$loginResponse");
        } else if (loginResponse["status"] == "error") {
          debugPrint("${loginResponse["code"]}");
          return;
        }
        return loginResponse;
      }
    } catch (e) {
      debugPrint("Error signing in: $e");
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
