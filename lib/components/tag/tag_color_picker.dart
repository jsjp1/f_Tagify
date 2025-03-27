import 'package:flutter/material.dart';

import 'package:tagify/api/tag.dart';
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
  Navigator.pop(context);
  await showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return TagColorPickerModal(
        onColorSelected: (Color color) async {
          // 선택된 색상으로 tagColor 업데이트
          // TODO: 에러 로그 스낵바
          final response = await updateTag(provider.loginResponse!["id"], tagId,
              tagName, color, provider.loginResponse!["accessToken"]);
        },
      );
    },
  );
}
