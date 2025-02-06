import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

class AuthButton extends StatelessWidget {
  final String logoImage;
  final String loginDescription;
  final Future<void> Function() loginFunction;
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
        onTap: () => loginFunction(),
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
              ),
              SizedBox(width: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
