import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

class TagContainer extends StatelessWidget {
  final String tagName;
  final double textSize;
  final Color? tagColor;
  final bool? isSelected;
  final GestureTapCallback? onTap;
  final bool? isLastButton;

  const TagContainer({
    super.key,
    required this.tagName,
    required this.textSize,
    this.tagColor,
    this.isSelected,
    this.onTap,
    this.isLastButton,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(left: 2.0, right: 4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: textSize + 7.0,
          constraints: BoxConstraints(minWidth: textSize + 3.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected == true
                  ? mainColor
                  : (isDarkMode
                      ? darkContentInstanceTagBorderColor
                      : contentInstanceTagBorderColor),
              width: isSelected == true ? 0.9 : 0.7,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: textSize / 1.75, vertical: textSize * 0.05),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlobalText(
                  localizeText: tagName,
                  textSize: textSize,
                  textColor: tagColor ?? Colors.grey,
                  isBold: true,
                  localization: false,
                ),
                if (isLastButton == false) ...[
                  SizedBox(width: 5.0),
                  GlobalText(
                    localizeText: "✕",
                    textColor: Colors.grey,
                    textSize: 10.0,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
