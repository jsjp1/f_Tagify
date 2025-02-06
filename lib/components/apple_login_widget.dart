import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:tagify/components/oauth_button.dart';
import 'package:tagify/api/auth.dart';
import 'package:tagify/screens/home_screen.dart';

class AppleLoginWidget extends StatelessWidget {
  AppleLoginWidget({super.key});

  Future<dynamic> _handleSignIn(BuildContext context) async {
    const String oauthProvider = "Apple";
    try {
      final AuthorizationCredentialAppleID user =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      String? oauthId, email, fullName;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      if (user.email == null) {
        // 이전에 로그인 한 적 존재 -> null값 제공
        debugPrint("Apple User Identifier is null");
        oauthId = prefs.getString("apple_user_id");
        email = prefs.getString("apple_email");
        fullName = prefs.getString("apple_full_name");
      } else {
        // 최초 로그인
        await prefs.setString("apple_user_id", user.userIdentifier!);
        await prefs.setString("apple_email", user.email ?? "");
        await prefs.setString("apple_full_name",
            "${user.givenName ?? ""} ${user.familyName ?? ""}".trim());

        oauthId = user.userIdentifier;
        email = user.email;
        fullName = "${user.givenName ?? ""} ${user.familyName ?? ""}".trim();

        debugPrint("Apple Login Data Saved clear");
      }

      dynamic loginResponse = await login(oauthId!, email ?? "");
      debugPrint("Login Response: $loginResponse");

      if (loginResponse["status"] == "failure") {
        // 회원이 존재하지 않는 경우, 회원가입 후 다시 로그인 시도
        final signupResponse = await signup({
          "username": fullName,
          "oauth_provider": oauthProvider,
          "oauth_id": oauthId,
          "email": email,
          "profile_image": "",
        });
        debugPrint("Signup Response: $signupResponse");

        if (signupResponse["status"] == "error") {
          debugPrint("Signup Error: status_code ${signupResponse["code"]}");
          return;
        }

        loginResponse = await login(oauthId, email ?? "");
        debugPrint("Re-login Response: $loginResponse");
      } else if (loginResponse["status"] == "error") {
        debugPrint("Login Error: status_code ${loginResponse["code"]}");
        return;
      }

      return loginResponse;
    } catch (e, _) {
      debugPrint("Apple Login Error: $e");
      if (e is PlatformException) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AuthButton(
          logoImage: "assets/img/apple_logo.png",
          loginDescription: "apple_login_button",
          loginFunction: () => _handleSignIn(context),
          buttonbackgroundColor: Colors.black,
          fontColor: Colors.white,
        ),
      ],
    );
  }
}
