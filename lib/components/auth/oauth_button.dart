import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagify/api/content.dart';

import 'package:tagify/global.dart';

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

          if (loginResponse != {}) {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            String loginResponseString = jsonEncode(loginResponse);

            debugPrint("HERE: $loginResponse");

            await loadAuthToken(
                loginResponse["access_token"]); // oauth_token 전역 변수 세팅

            await prefs.setString("loginResponse", loginResponseString);
            await prefs.setBool("isLoggedIn", true);
            debugPrint("Save Login status success");

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
              arguments: loginResponse,
            );
          }
        },
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: buttonbackgroundColor,
            border: Border.all(color: Colors.black, width: 0.15),
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
