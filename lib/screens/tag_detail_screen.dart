import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/content_widget.dart';
import 'package:tagify/components/home/app_bar.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class TagDetailScreen extends StatefulWidget {
  final Tag tag;

  const TagDetailScreen({super.key, required this.tag});

  @override
  TagDetailScreenState createState() => TagDetailScreenState();
}

class TagDetailScreenState extends State<TagDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

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
                      userId: provider.loginResponse!["id"],
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
