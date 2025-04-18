import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagify/global.dart';
import 'package:tagify/screens/home_screen.dart';
import 'package:tagify/screens/splash_screen.dart';

class AuthButton extends StatelessWidget {
  final String logoImage;
  final String loginDescription;
  final Future<Map<String, dynamic>> Function() loginFunction;
  final Color buttonbackgroundColor;
  final Color fontColor;

  const AuthButton({
    super.key,
    required this.logoImage,
    required this.loginDescription,
    required this.loginFunction,
    required this.buttonbackgroundColor,
    required this.fontColor,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * (0.8);
    final double buttonHeight = 70;

    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: GestureDetector(
        onTap: () async {
          Map<String, dynamic> loginResponse = await loginFunction();
          debugPrint("oauth_button.dart: $loginResponse");

          if (loginResponse.isNotEmpty) {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            String loginResponseString = jsonEncode(loginResponse);

            await prefs.setString("loginResponse", loginResponseString);
            await prefs.setBool("isLoggedIn", true);
            await prefs.setString(
                "access_token", loginResponse["access_token"]);
            await prefs.setString(
                "refresh_token", loginResponse["refresh_token"]);

            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    SplashScreen(loginResponse: loginResponse),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 450),
              ),
              (route) => false,
            );
          }
        },
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: buttonbackgroundColor,
            border: Border.all(color: Colors.black, width: 0.7),
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: EdgeInsets.all(0.0),
                child: Image.asset(
                  logoImage,
                  width: 40.0,
                  height: 40.0,
                ),
              ),
              GlobalText(
                localizeText: loginDescription,
                textSize: 25.0,
                textColor: fontColor,
                isBold: false,
                overflow: TextOverflow.clip,
              ),
              SizedBox(width: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
