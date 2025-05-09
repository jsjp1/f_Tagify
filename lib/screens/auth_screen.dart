import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:tagify/components/auth/google_login_widget.dart';
import 'package:tagify/components/auth/apple_login_widget.dart';
import 'package:tagify/global.dart';
import 'package:tagify/utils/animated_icon_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
              width: screenWidth * (0.8),
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(child: SizedBox.shrink()),
          Image.asset(
            width: MediaQuery.of(context).size.width * (0.275),
            height: MediaQuery.of(context).size.height * (0.15),
            "assets/app_main_icons_1024_1024.png",
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlobalText(
                localizeText: "Tagify",
                letterSpacing: -2.0,
                textSize: 45.0,
                isBold: true,
                overflow: TextOverflow.clip,
                localization: false,
              ),
              GlobalText(
                localizeText: "auth_screen_top_description_text",
                textSize: 17.0,
                isBold: true,
                overflow: TextOverflow.clip,
                localization: true,
              ),
            ],
          ),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
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
            textSize: 17.0,
            overflow: TextOverflow.clip,
            localization: true,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 1.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 10.0),
              children: _buildLocalizedTermsText(context),
            ),
          ),
        ),
      ],
    );
  }
}

List<InlineSpan> _buildLocalizedTermsText(BuildContext context) {
  final template = tr("auth_screen_bottom_warning_text");

  final termsLink = TextSpan(
    text: tr("terms_of_service"),
    style: TextStyle(
      color: Colors.grey[500],
      decoration: TextDecoration.underline,
    ),
    recognizer: TapGestureRecognizer()
      ..onTap = () {
        launchUrl(Uri.parse("https://tagi.jieeen.kr/terms-of-service"));
      },
  );

  final privacyLink = TextSpan(
    text: tr("privacy_policy"),
    style: TextStyle(
      color: Colors.grey[500],
      decoration: TextDecoration.underline,
    ),
    recognizer: TapGestureRecognizer()
      ..onTap = () {
        launchUrl(Uri.parse("https://tagi.jieeen.kr/privacy-policy"));
      },
  );

  final spans = <InlineSpan>[];

  final regex = RegExp(r'\{terms\}|\{privacy\}');
  int lastMatchEnd = 0;

  for (final match in regex.allMatches(template)) {
    final textBefore = template.substring(lastMatchEnd, match.start);
    if (textBefore.isNotEmpty) spans.add(TextSpan(text: textBefore));

    if (match.group(0) == '{terms}') {
      spans.add(termsLink);
    } else if (match.group(0) == '{privacy}') {
      spans.add(privacyLink);
    }

    lastMatchEnd = match.end;
  }

  if (lastMatchEnd < template.length) {
    spans.add(TextSpan(text: template.substring(lastMatchEnd)));
  }

  return spans;
}
