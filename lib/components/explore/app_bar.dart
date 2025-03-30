import 'package:flutter/material.dart';

import 'package:tagify/global.dart';

class TagifyExploreAppBar extends StatelessWidget {
  final String appBarName;

  const TagifyExploreAppBar({super.key, required this.appBarName});

  @override
  Widget build(BuildContext context) {
    final appBarTextWidth = MediaQuery.of(context).size.width * (0.7);

    return Container(
      width: double.infinity,
      height: appBarHeight,
      color: whiteBackgroundColor,
      padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 5.0),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: appBarTextWidth,
            child: GlobalText(
              localizeText: appBarName,
              textSize: 25.0,
              isBold: true,
              textColor: Colors.black,
              overflow: TextOverflow.visible,
              localization: false,
            ),
          ),
        ],
      ),
    );
  }
}
