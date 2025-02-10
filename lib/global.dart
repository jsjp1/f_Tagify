import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const Color mainColor = Color.fromARGB(255, 205, 20, 31);
const Color whiteBackgroundColor = Colors.white;
const Color blackBackgroundColor = Colors.black54;
const Color noticeWidgetColor = Color.fromARGB(255, 240, 243, 243);
const Color videoTextBarColor = Color.fromARGB(255, 228, 228, 228);
const Color timeContainerColor = Color.fromARGB(200, 225, 225, 225);

class GlobalText extends StatelessWidget {
  final String localizeText;
  final double textSize;
  final bool isBold;
  final Color textColor;

  const GlobalText(
      {super.key,
      required this.localizeText,
      required this.textSize,
      required this.isBold,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      localizeText,
      style: TextStyle(
        color: textColor,
        fontSize: textSize,
        fontFamily: "YoutubeFont",
        fontWeight: isBold ? FontWeight.bold : null,
      ),
    ).tr();
  }
}
