import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class TagColorPickerModal extends StatefulWidget {
  final Function(Color) onColorSelected;

  const TagColorPickerModal({super.key, required this.onColorSelected});

  @override
  TagColorPickerModalState createState() => TagColorPickerModalState();
}

class TagColorPickerModalState extends State<TagColorPickerModal> {
  Color selectedColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final provider = Provider.of<TagifyProvider>(context, listen: false);
    final List<Color> userColor =
        provider.loginResponse!["is_premium"] ? premiumColors : basicColors;

    return SizedBox(
      height: 140.0,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: GlobalText(
                  localizeText: "tag_color_picker_select_color",
                  textSize: 20.0,
                  isBold: true),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 프리미엄 회원은 커스텀 색 생성 가능
                provider.loginResponse!["is_premium"]
                    ? GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              Color tempColor = selectedColor;
                              return AlertDialog(
                                buttonPadding: EdgeInsets.zero,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 0.0),
                                actionsPadding:
                                    EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                                surfaceTintColor: Colors.transparent,
                                backgroundColor: isDarkMode
                                    ? darkNoticeWidgetColor
                                    : noticeWidgetColor,
                                title: Padding(
                                  padding: EdgeInsets.only(bottom: 20.0),
                                  child: GlobalText(
                                    localizeText:
                                        "tag_color_picker_custom_color_select",
                                    textSize: 20.0,
                                    isBold: true,
                                  ),
                                ),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: selectedColor,
                                    onColorChanged: (Color c) {
                                      tempColor = c;
                                    },
                                    pickerAreaBorderRadius:
                                        BorderRadius.circular(10.0),
                                    enableAlpha: true,
                                    showLabel: false,
                                    pickerAreaHeightPercent: 0.8,
                                    displayThumbColor: false,
                                    portraitOnly: true,
                                    // hexInputBar: true,
                                    labelTextStyle:
                                        TextStyle(fontFamily: "YoutubeFont"),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: GlobalText(
                                      localizeText: "tag_color_picker_cancel",
                                      textSize: 15.0,
                                      textColor: isDarkMode
                                          ? whiteBackgroundColor
                                          : darkNoticeWidgetColor,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: GlobalText(
                                      localizeText: "tag_color_picker_ok",
                                      textSize: 15.0,
                                      isBold: true,
                                      textColor: mainColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedColor = tempColor;
                                      });
                                      widget.onColorSelected(tempColor);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Container(
                            margin: EdgeInsets.all(8),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: Icon(Icons.add, color: blackBackgroundColor),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                ...userColor.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                      widget.onColorSelected(color);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                      child: Container(
                        margin: EdgeInsets.all(8),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> themeColorChange(BuildContext context, TagifyProvider provider,
    int tagId, String tagName) async {
  return await showModalBottomSheet<void>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return TagColorPickerModal(
        onColorSelected: (Color color) async {
          final success = await provider.pvUpdateTag(tagId, tagName, color);

          if (success) {
            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: snackBarColor,
                content: GlobalText(
                    localizeText: "tag_color_picker_color_select_error",
                    textSize: 15.0),
                duration: Duration(seconds: 1),
              ),
            );
            return;
          }
        },
      );
    },
  );
}
