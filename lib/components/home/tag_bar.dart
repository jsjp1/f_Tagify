import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/components/contents/content_widget.dart';
import 'package:tagify/provider.dart';

class TagBar extends StatefulWidget {
  final int userId;
  final double tagBarHeight;
  final GlobalKey<ContentWidgetState> contentWidgetKey;
  String currentTag = "all";

  TagBar({
    super.key,
    required this.userId,
    required this.contentWidgetKey,
    required this.tagBarHeight,
  });

  @override
  TagBarState createState() => TagBarState();
}

class TagBarState extends State<TagBar> {
  @override
  Widget build(BuildContext context) {
    final TagifyProvider provider = context.watch<TagifyProvider>();

    return Column(
      children: [
        Container(
          height: widget.tagBarHeight,
          color: noticeWidgetColor,
          child: Row(
            children: [
              SizedBox(width: 10.0),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    widget.currentTag = "all";
                  });
                  provider.currentTag = "all";
                },
                child: TagContainer(
                  tagName: "tag_bar_tagname_all",
                  tagBarHeight: widget.tagBarHeight,
                  currentSelectedTag: widget.currentTag == "all",
                ),
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    widget.currentTag = "bookmark";
                  });
                  provider.currentTag = "bookmark";
                },
                child: TagContainer(
                  tagName: "tag_bar_tagname_bookmark",
                  tagBarHeight: widget.tagBarHeight,
                  currentSelectedTag: widget.currentTag == "bookmark",
                ),
              ),
            ],
            // TODO: Future Builder로 태그 추가?
            // 태그에 저장된 이름을 함수에 건네기
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

class TagContainer extends StatelessWidget {
  final String tagName;
  final double tagBarHeight;
  bool currentSelectedTag;

  TagContainer(
      {super.key,
      required this.tagName,
      required this.tagBarHeight,
      required this.currentSelectedTag});

  @override
  Widget build(BuildContext context) {
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
                ? blackBackgroundColor
                : whiteBackgroundColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(3.0),
              child: GlobalText(
                localizeText: tagName,
                textSize: 12.0,
                textColor: currentSelectedTag ? Colors.white : Colors.black,
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
