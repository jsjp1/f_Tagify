import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String logoImage;
  final String loginDescription;
  final Future<void> Function() loginFunction;

  const AuthButton(
      {super.key,
      required this.logoImage,
      required this.loginDescription,
      required this.loginFunction});

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
            color: Colors.white10,
            border: Border.all(color: Colors.black, width: 0.03),
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
              Text(
                loginDescription,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w100,
                  color: Colors.black87,
                ),
              ).tr(),
            ],
          ),
        ),
      ),
    );
  }
}
