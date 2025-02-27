import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/content_widget.dart';
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
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: Container(
              color: Colors.white.withAlpha(160),
            ),
          ),
        ),
        elevation: 0.0,
        toolbarHeight: appBarHeight,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/app_logo_white.png",
                  height: logoImageHeight,
                  color: widget.tag.color,
                  colorBlendMode: BlendMode.srcIn,
                ),
                GlobalText(
                  localizeText: widget.tag.tagName,
                  textSize: 30.0,
                  isBold: true,
                  localization: false,
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: noticeWidgetColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: ContentWidget(
          // TODO: 태그 아래 속해있는 콘텐츠만 가져올 수 있도록 ContentWidget 변경
          userId: provider.loginResponse!["id"],
        ),
      ),
    );
  }
}
