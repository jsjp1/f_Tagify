import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const Color mainColor = Color.fromARGB(255, 196, 48, 43);
const Color whiteBackgroundColor = Colors.white;
const Color blackBackgroundColor = Colors.black54;
const Color noticeWidgetColor = Color.fromARGB(255, 237, 242, 243);

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
