import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

// TODO: tagFolderColor 변경할 수 있도록
class TagBoxInstance extends StatelessWidget {
  final String tagName;
  final bool isTagAddFolder;
  final GestureTapCallback onTap;

  const TagBoxInstance(
      {super.key,
      required this.tagName,
      required this.isTagAddFolder,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double boxWidth = MediaQuery.of(context).size.width * (0.47);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          !isTagAddFolder
              ? Positioned(
                  right: 5.0,
                  top: 5.0,
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    color: tagFolderColor,
                  ),
                )
              : SizedBox.shrink(),
          !isTagAddFolder
              ? Positioned(
                  top: 20.0,
                  right: 3.0,
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    color: whiteBackgroundColor,
                  ),
                )
              : SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Container(
              width: boxWidth * (0.85),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: whiteBackgroundColor,
              ),
              child: Center(
                child: Text(tagName),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
