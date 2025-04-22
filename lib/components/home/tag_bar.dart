import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/components/contents/content_widget.dart';
import 'package:tagify/provider.dart';

class TagBar extends StatefulWidget {
  final int userId;
  final double tagBarHeight;
  final GlobalKey<ContentWidgetState> contentWidgetKey;

  const TagBar({
    super.key,
    required this.userId,
    required this.contentWidgetKey,
    required this.tagBarHeight,
  });

  @override
  TagBarState createState() => TagBarState();
}

class TagBarState extends State<TagBar> {
  String currentTag = "all";

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return Column(
      children: [
        Container(
          color: isDarkMode ? darkNoticeWidgetColor : noticeWidgetColor,
          height: widget.tagBarHeight,
          child: Row(
            children: [
              SizedBox(width: 10.0),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    currentTag = "all";
                  });
                  provider.currentTag = "all";
                },
                child: TagBarContainer(
                  tagName: "tag_bar_tagname_all",
                  tagBarHeight: widget.tagBarHeight,
                  currentSelectedTag: currentTag == "all",
                ),
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    currentTag = "bookmark";
                  });
                  provider.currentTag = "bookmark";
                },
                child: TagBarContainer(
                  tagName: "tag_bar_tagname_bookmark",
                  tagBarHeight: widget.tagBarHeight,
                  currentSelectedTag: currentTag == "bookmark",
                ),
              ),
              // TODO: Future Builder로 태그 추가?
              // 태그에 저장된 이름을 함수에 건네기
            ],
          ),
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

class TagBarContainer extends StatelessWidget {
  final String tagName;
  final double tagBarHeight;
  final bool currentSelectedTag;

  const TagBarContainer(
      {super.key,
      required this.tagName,
      required this.tagBarHeight,
      required this.currentSelectedTag});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: IntrinsicWidth(
        child: Container(
          height: tagBarHeight * (0.65),
          constraints: BoxConstraints(
            minWidth: 50.0,
            maxWidth: 90.0,
          ),
          decoration: BoxDecoration(
            color: currentSelectedTag
                ? (isDarkMode ? noticeWidgetColor : blackBackgroundColor)
                : (isDarkMode ? darkNoticeWidgetColor : noticeWidgetColor),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(3.0),
              child: GlobalText(
                localizeText: tagName,
                textSize: 12.0,
                textColor: currentSelectedTag
                    ? (isDarkMode ? blackBackgroundColor : whiteBackgroundColor)
                    : (isDarkMode
                        ? whiteBackgroundColor
                        : blackBackgroundColor),
                isBold: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
