import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/components/analyze/content_edit_widget.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';

class ContentEditScreen extends StatefulWidget {
  final Content content;

  const ContentEditScreen({super.key, required this.content});

  @override
  ContentEditScreenState createState() => ContentEditScreenState();
}

class ContentEditScreenState extends State<ContentEditScreen> {
  @override
  Widget build(BuildContext context) {
    final double pageWidth = MediaQuery.of(context).size.width * (0.9);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: pageWidth,
                child: Column(
                  children: [
                    // appBar 부분
                    SizedBox(
                      height: safeAreaHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(CupertinoIcons.back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),

                    // 컨텐츠 정보 나열, 스크롤 가능 부분
                    Expanded(
                      child: ContentEditWidget(
                        content: widget.content,
                        isEdit: true,
                        widgetWidth: pageWidth,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
