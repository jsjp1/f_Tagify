import 'dart:async';

import 'package:flutter/material.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class TagColorPickerModal extends StatefulWidget {
  final Function(Color) onColorSelected;

  const TagColorPickerModal({super.key, required this.onColorSelected});

  @override
  TagColorPickerModalState createState() => TagColorPickerModalState();
}

class TagColorPickerModalState extends State<TagColorPickerModal> {
  final List<Color> colors = [
    // TODO: 회원 등급에 따라 구별
    mainColor,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
  ];

  Color selectedColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 150.0,
        child: Row(
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = color;
                });
                widget.onColorSelected(color);
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.all(8),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            );
          }).toList(),
        ),
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
