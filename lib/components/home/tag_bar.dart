import 'package:flutter/material.dart';

class TagBar extends StatefulWidget {
  final double tagBarHeight;

  const TagBar({super.key, required this.tagBarHeight});

  @override
  TagBarState createState() => TagBarState();
}

class TagBarState extends State<TagBar> {
  // TODO:

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: widget.tagBarHeight,
      color: Colors.black,
    );
  }
}
