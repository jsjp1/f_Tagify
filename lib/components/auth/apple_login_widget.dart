import 'dart:convert';
import 'dart:io';

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
        webAuthenticationOptions: Platform.isAndroid
            ? WebAuthenticationOptions(
                clientId: "com.ellipsoid.tagi.socialLogin",
                redirectUri: Uri.parse(
                    "https://violet-cumbersome-morning.glitch.me/callbacks/sign_in_with_apple"))
            : null,
      );

      String? idToken = user.identityToken;

      if (idToken == null) {
        debugPrint("Error: Apple Id Token is null");
        return {};
      }

      final parts = idToken.split('.');
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> decoded = jsonDecode(payload);

      String? email = decoded["email"];
      String? oauthId = decoded["sub"];

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      String fullName =
          "${user.givenName ?? ""} ${user.familyName ?? ""}".trim();

      if (email == null) {
        email = prefs.getString("apple_email") ?? "noemail@apple.com";
      } else {
        await prefs.setString("apple_user_id", oauthId ?? "");
        await prefs.setString("apple_email", email);
        await prefs.setString("apple_full_name", fullName);
      }

      if (fullName.trim() == "") {
        final String? _name = prefs.getString("apple_full_name");
        if (_name == null || _name == "") {
          fullName = "${oauthProvider}_${idToken.substring(0, 5)}";
        } else {
          fullName = _name;
        }
      }

      ApiResponse<Map<String, dynamic>> loginResponse = await login(
          oauthProvider,
          idToken,
          fullName,
          oauthId ?? "",
          email,
          "",
          context.deviceLocale.languageCode.toString());

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
