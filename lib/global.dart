import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const Color mainColor = Color.fromARGB(255, 205, 20, 31);
const Color whiteBackgroundColor = Colors.white;
const Color blackBackgroundColor = Colors.black;
const Color noticeWidgetColor = Color.fromARGB(255, 244, 244, 244);
const Color timeContainerColor = Color.fromARGB(200, 225, 225, 225);
const Color tagColor = Color.fromARGB(255, 50, 50, 50);
const Color containerTitleColor = Color.fromARGB(255, 78, 78, 78);
const Color profileButtonContainerColor = Color.fromARGB(255, 200, 200, 200);
const Color navigationSearchBarColor = Colors.white70;
const Color contentInstanceTagTextColor = Colors.indigo;
const Color contentInstanceTagBorderColor = Color.fromARGB(255, 209, 209, 209);
const Color analyzeScreenTextColor = Color.fromARGB(255, 133, 133, 133);

class GlobalText extends StatelessWidget {
  final String localizeText;
  final double textSize;
  bool localization;
  bool? isBold;
  Color? textColor;
  TextOverflow? overflow;

  GlobalText({
    super.key,
    required this.localizeText,
    required this.textSize,
    this.isBold,
    this.textColor,
    this.overflow,
    this.localization = true,
  });

  @override
  Widget build(BuildContext context) {
    return localization
        ? Text(
            localizeText,
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
              fontFamily: "YoutubeFont",
              fontWeight:
                  (isBold ?? false) ? FontWeight.bold : FontWeight.normal,
              overflow: overflow,
            ),
          ).tr()
        : Text(
            localizeText,
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
              fontFamily: "YoutubeFont",
              fontWeight:
                  (isBold ?? false) ? FontWeight.bold : FontWeight.normal,
              overflow: overflow,
            ),
          );
  }
}
