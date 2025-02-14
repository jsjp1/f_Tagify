import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/api/content.dart';

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
  void initState() {
    super.initState();
    isBookMarked = widget.content.bookmark;
  }

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
              height: widget.instanceHeight * (0.05),
            ),
            SizedBox(
              height: widget.instanceHeight * (0.25),
              child: Row(
                children: [
                  SizedBox(width: 10.0),
                  // 왼쪽 아이콘 그룹
                  Row(
                    children: [
                      // Icon(widget.content is Video
                      //     ? CupertinoIcons.play
                      //     : Icons.text_snippet_outlined),
                      SizedBox(width: 5.0),
                      Text("🔥", style: TextStyle(fontSize: 15.0)),
                      SizedBox(
                        width: widget.instanceWidth * (0.7),
                        child: GlobalText(
                            localizeText: widget.content.title,
                            textSize: 15.0,
                            isBold: true,
                            textColor: containerTitleColor,
                            overflow: TextOverflow.ellipsis),
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
                          onPressed: () async {
                            setState(() {
                              isBookMarked = !isBookMarked;
                            });
                            // TODO: 즐겨찾기 로직 추가
                            dynamic _ = await toggleBookmark(widget.content.id);
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
                          onPressed: () {
                            // TODO
                          },
                        ),
                      ),
                      SizedBox(width: 10.0),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: widget.instanceWidth,
              height: widget.instanceHeight * (0.45),
              child: Stack(
                children: [
                  // 컨테이너 상단 좌측 썸네일
                  Positioned(
                    left: 20.0,
                    top: 5.0,
                    height: widget.instanceHeight * (0.35),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
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
                  Positioned(
                    left: widget.instanceWidth * (0.4),
                    top: 5.0,
                    child: SizedBox(
                      width: widget.instanceWidth * (0.5),
                      height: widget.instanceHeight * (0.35),
                      child: GlobalText(
                        localizeText: widget.content.description,
                        textSize: 10.0,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: widget.instanceHeight * (0.03)),
            SizedBox(
              height: widget.instanceHeight * (0.15),
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.content.tags.length,
                  itemBuilder: (context, index) {
                    return TagContainer(
                      tagName: widget.content.tags[index],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: widget.instanceHeight * (0.025)),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: whiteBackgroundColor,
          border: Border.all(
            color: contentInstanceTagBorderColor,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 0.0),
            child: GlobalText(
              localizeText: tagName,
              textSize: 10.0,
              textColor: contentInstanceTagTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
