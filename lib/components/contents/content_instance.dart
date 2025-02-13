import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';

class ContentInstance extends StatefulWidget {
  final double instanceWidth;
  final double instanceHeight;
  final Content content;

  const ContentInstance({
    super.key,
    required this.instanceWidth,
    required this.instanceHeight,
    required this.content,
  });

  @override
  ContentInstanceState createState() => ContentInstanceState();
}

class ContentInstanceState extends State<ContentInstance> {
  bool isBookMarked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
      child: Container(
        width: widget.instanceWidth,
        height: widget.instanceHeight,
        decoration: BoxDecoration(
          color: whiteBackgroundColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
                color: const Color.fromARGB(255, 225, 225, 225),
                blurRadius: 5.0,
                spreadRadius: 0.01,
                offset: Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            // 콘텐츠 컨테이너 타이틀 바
            SizedBox(
              height: widget.instanceHeight * (0.2),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                child: Row(
                  children: [
                    // 왼쪽 아이콘 그룹
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon(widget.content is Video
                        //     ? CupertinoIcons.play
                        //     : Icons.text_snippet_outlined),
                        SizedBox(width: 5.0),
                        Text("🔥", style: TextStyle(fontSize: 20.0)),
                        SizedBox(width: 3.0),
                        SizedBox(
                          width: widget.instanceWidth * (0.7),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GlobalText(
                                localizeText: widget.content.title,
                                textSize: 15.0,
                                isBold: true,
                                textColor: containerTitleColor,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 27.0,
                          height: 24.0,
                          child: IconButton(
                            highlightColor: Colors.transparent,
                            icon: Icon(isBookMarked
                                ? Icons.bookmark_sharp
                                : Icons.bookmark_outline_sharp),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                isBookMarked = !isBookMarked;
                                debugPrint("$isBookMarked");
                              });
                              // TODO: 로직 추가
                            },
                          ),
                        ),
                        SizedBox(
                          width: 27.0,
                          height: 24.0,
                          child: IconButton(
                            highlightColor: Colors.transparent,
                            icon: Icon(Icons.more_vert_sharp),
                            padding: EdgeInsets.zero,
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(width: 10.0),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: widget.instanceWidth,
              height: widget.instanceHeight * (0.5),
              child: Stack(
                children: [
                  // 컨테이너 상단 우측 썸네일
                  Positioned(
                    left: 20.0,
                    top: 20.0,
                    height: widget.instanceHeight * (0.35),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5.0,
                              spreadRadius: 3.0,
                            ),
                          ],
                        ),
                        child: Image.network(
                          widget.content.thumbnail,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagContainer extends StatelessWidget {
  final String tagName;

  const TagContainer({super.key, required this.tagName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(1.0),
        child: GlobalText(localizeText: tagName, textSize: 10.0),
      ),
    );
  }
}
