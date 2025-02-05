import 'package:Tagify/global.dart';
import 'package:flutter/material.dart';

import 'package:Tagify/components/google_login_widget.dart';

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
      backgroundColor: whiteBackgroundColor,
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
    return Container(
      color: Colors.green,
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
        GoogleLoginWidget(),
      ],
    );
  }
}
