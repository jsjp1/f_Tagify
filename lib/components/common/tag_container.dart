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
    return Padding(
      padding: EdgeInsets.only(left: 2.0, right: 4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: contentInstanceTagBorderColor,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
              child: Row(
                textBaseline: TextBaseline.alphabetic,
                children: [
                  GlobalText(
                    localizeText: tagName,
                    textSize: textSize!,
                    textColor: tagColor ?? Colors.grey,
                    isBold: true,
                    localization: false,
                  ),
                  isLastButton != null
                      ? (isLastButton!
                          ? SizedBox.shrink()
                          : SizedBox(width: 5.0))
                      : SizedBox.shrink(),
                  isLastButton != null
                      ? (isLastButton!
                          ? SizedBox.shrink()
                          : Text("✕",
                              style: TextStyle(
                                  fontSize: 10.0, color: Colors.grey)))
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
