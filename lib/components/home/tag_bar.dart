import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

class TagBar extends StatefulWidget {
  final double tagBarHeight;

  const TagBar({super.key, required this.tagBarHeight});

  @override
  TagBarState createState() => TagBarState();
}

class TagBarState extends State<TagBar> {
  // TODO

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: widget.tagBarHeight,
          color: noticeWidgetColor,
        ),
        Divider(
          color: Colors.grey,
          height: 1,
          thickness: 0.1,
        ),
      ],
    );
  }
}
