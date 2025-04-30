import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:tagify/components/auth/oauth_button.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/api/user.dart';

class AppleLoginWidget extends StatelessWidget {
  const AppleLoginWidget({super.key});

  Future<Map<String, dynamic>> _handleSignIn(BuildContext context) async {
    const String oauthProvider = "Apple";
    try {
      final AuthorizationCredentialAppleID user =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // TODO: email이 ""으로 돼, login이 불가한 문제
      String? oauthId = user.userIdentifier;
      String? idToken = user.identityToken;

      if (oauthId == null) {
        debugPrint("Error: Apple userIdentifier is null");
        return {};
      }
      if (idToken == null) {
        debugPrint("Error: Apple Id Token is null");
        return {};
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      String? email = user.email;
      String fullName =
          "${user.givenName ?? ""} ${user.familyName ?? ""}".trim();

      if (email == null) {
        email = prefs.getString("apple_email") ?? "noemail@apple.com";
        fullName = prefs.getString("apple_full_name") ??
            "${oauthProvider}_${idToken.substring(0, 5)}";
      } else {
        await prefs.setString("apple_user_id", oauthId);
        await prefs.setString("apple_email", email);
        await prefs.setString("apple_full_name", fullName);
      }

      ApiResponse<Map<String, dynamic>> loginResponse = await login(
          oauthProvider,
          idToken,
          fullName,
          oauthId,
          email,
          "",
          context.locale.toString());

      // TODO: 에러 처리
      if (loginResponse.errorMessage != null) {
        debugPrint("Login Error: ${loginResponse.errorMessage}");
      }

      return loginResponse.data ?? {};
    } catch (e, stackTrace) {
      debugPrint("Unexpected error: $e\n$stackTrace");
      return {};
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
