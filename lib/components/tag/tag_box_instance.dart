import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

class TagBoxInstance extends StatelessWidget {
  final String tagName;

  const TagBoxInstance({super.key, required this.tagName});

  @override
  Widget build(BuildContext context) {
    final double boxWidth = MediaQuery.of(context).size.width * (0.47);

    return Container(
      width: boxWidth,
      decoration: BoxDecoration(
        color: tagBoxInstanceColor,
        border: Border.all(width: 0.01),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        child: Center(
          child: Text(tagName),
        ),
      ),
    );
  }
}
