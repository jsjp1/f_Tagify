import 'package:flutter/material.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/content_widget.dart';
import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/global.dart';

class TagDetailScreen extends StatefulWidget {
  final Tag tag;

  const TagDetailScreen({super.key, required this.tag});

  @override
  TagDetailScreenState createState() => TagDetailScreenState();
}

class TagDetailScreenState extends State<TagDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          color: noticeWidgetColor,
          child: Stack(
            children: [
              Column(
                children: [
                  TagifyAppBar(
                    addText: "/ ${widget.tag.tagName}",
                    appIconColor: widget.tag.color,
                  ),
                  Expanded(
                    child: ContentWidget(
                      tagSelectedId: widget.tag.id,
                      tagSelectedName: widget.tag.tagName,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
