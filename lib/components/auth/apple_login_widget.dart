import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:tagify/components/auth/oauth_button.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/api/auth.dart';

class AppleLoginWidget extends StatelessWidget {
  AppleLoginWidget({super.key});

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

      String? oauthId = user.userIdentifier;
      if (oauthId == null) {
        debugPrint("Error: Apple userIdentifier is null");
        return {};
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      String? email = user.email;
      String fullName =
          "${user.givenName ?? ""} ${user.familyName ?? ""}".trim();

      if (email == null) {
        email = prefs.getString("apple_email") ?? "";
        fullName = prefs.getString("apple_full_name") ?? fullName;
      } else {
        await prefs.setString("apple_user_id", oauthId);
        await prefs.setString("apple_email", email);
        await prefs.setString("apple_full_name", fullName);
      }

      ApiResponse<Map<String, dynamic>> loginResponse =
          await login(oauthId, email);

      if (loginResponse.errorMessage == "failure") {
        final ApiResponse<Map<String, dynamic>> signupResponse = await signup({
          "username": fullName,
          "oauth_provider": oauthProvider,
          "oauth_id": oauthId,
          "email": email,
          "profile_image": "",
        });

        if (signupResponse.errorMessage == "error") {
          debugPrint("Signup Error: status_code ${signupResponse.statusCode}");
          return {};
        }

        loginResponse = await login(oauthId, email);
      } else if (loginResponse.errorMessage == "error") {
        debugPrint("Login Error: status_code ${loginResponse.statusCode}");
        return {};
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
