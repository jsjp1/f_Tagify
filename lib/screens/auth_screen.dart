import 'package:flutter/material.dart';

import 'package:tagify/components/auth/google_login_widget.dart';
import 'package:tagify/components/auth/apple_login_widget.dart';
import 'package:tagify/global.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width * (0.9);
    final double topSectionHeight = MediaQuery.of(context).size.height * (0.7);
    final double bottomSectionHeight =
        MediaQuery.of(context).size.height * (0.3);

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: screenWidth,
              height: topSectionHeight,
              child: AuthScreenTopSection(),
            ),
            SizedBox(
              width: screenWidth,
              height: bottomSectionHeight,
              child: AuthScreenBottomSection(),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScreenTopSection extends StatelessWidget {
  const AuthScreenTopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * (0.2)),
        Hero(
          tag: "tagifyAppIcon",
          child: Image.asset(
            height: MediaQuery.of(context).size.height * (0.2),
            "assets/img/tagify_app_main_icon_3d_transparent.png",
          ),
        ),
        GlobalText(
          localizeText: "Tagify",
          textSize: 36.0,
          isBold: true,
          overflow: TextOverflow.clip,
          localization: false,
        ),
        GlobalText(
          localizeText: "auth_screen_top_description_text",
          textSize: 16.0,
          isBold: true,
          overflow: TextOverflow.clip,
          localization: true,
        ),
      ],
    );
  }
}

class AuthScreenBottomSection extends StatelessWidget {
  const AuthScreenBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GoogleLoginWidget(),
        AppleLoginWidget(),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: GlobalText(
            isBold: false,
            localizeText: "auth_screen_bottom_description_text",
            textSize: 15.0,
            overflow: TextOverflow.clip,
            localization: true,
          ),
        ),
      ],
    );
  }
}
