import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/analyze/new_tag_modal.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class ContentEditWidget extends StatefulWidget {
  final double widgetWidth;
  Content content;

  ContentEditWidget({
    super.key,
    required this.widgetWidth,
    required this.content,
  });

  @override
  ContentEditWidgetState createState() => ContentEditWidgetState();
}

class ContentEditWidgetState extends State<ContentEditWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();

    titleController.text = widget.content.title;
    descriptionController.text = widget.content.description;

    if (widget.content.tags.length >= 3) {
      // 콘텐츠당 최대 태그 개수 3개로 제한
      widget.content.tags = widget.content.tags.sublist(0, 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: widget.widgetWidth * 0.9,
              child: Column(
                children: [
                  const SizedBox(height: 10.0),
                  Stack(
                    children: [
                      // 썸네일 부분
                      SizedBox(
                        height: 175.0,
                        child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: CachedNetworkImage(
                              imageUrl: widget.content.thumbnail,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return SizedBox.expand();
                              },
                            )),
                      ),
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: IconButton(
                          icon: isBookmarked
                              ? Icon(Icons.bookmark, color: mainColor)
                              : Icon(Icons.bookmark_border, color: mainColor),
                          onPressed: () {
                            setState(() {
                              isBookmarked = !isBookmarked;
                              widget.content.bookmark = isBookmarked;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  // 제목 부분
                  const SizedBox(height: 50.0),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: GlobalText(
                      localizeText: "analyze_screen_title",
                      textSize: 15.0,
                      textColor: analyzeScreenTextColor,
                      isBold: true,
                      localization: true,
                    ),
                  ),
                  // 제목 지우기 버튼
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontSize: 17.5),
                    cursorColor: mainColor,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: mainColor),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(CupertinoIcons.delete_left_fill),
                        onPressed: () {
                          titleController.clear();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  // 설명 부분
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: GlobalText(
                      localizeText: "analyze_screen_description",
                      textSize: 15.0,
                      textColor: analyzeScreenTextColor,
                      isBold: true,
                      localization: true,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(fontSize: 13.0),
                    cursorColor: mainColor,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: mainColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: mainColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: IconButton(
                          icon: const Icon(CupertinoIcons.delete_left_fill),
                          onPressed: () {
                            descriptionController.clear();
                          },
                        ),
                      ),
                    ),
                    maxLines: 3,
                    minLines: 3,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                  const SizedBox(height: 30.0),
                  // TODO: 추천 태그 부분 만들기
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: GlobalText(
                      localizeText: "analyze_screen_tags",
                      textSize: 15.0,
                      textColor: analyzeScreenTextColor,
                      isBold: true,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    height: 25.0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(
                            widget.content.tags.length + 1,
                            (index) {
                              if (index < widget.content.tags.length) {
                                return TagContainer(
                                  tagName: widget.content.tags[index],
                                  onPressed: () {
                                    setState(() {
                                      widget.content.tags.removeAt(index);
                                    });
                                  },
                                  isLastButton: false,
                                );
                              } else {
                                return TagContainer(
                                  tagName: "+",
                                  onPressed: () {
                                    if (widget.content.tags.length == 3) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: snackBarColor,
                                          content: GlobalText(
                                              localizeText:
                                                  "content_edit_widget_no_more_tags_error",
                                              textSize: 15.0),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                      return;
                                    }

                                    // 태그 생성 로직
                                    setTagBottomModal(context,
                                        (String newTagName) {
                                      setState(() {
                                        widget.content.tags.add(newTagName);
                                      });
                                    });
                                  },
                                  isLastButton: true,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30.0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                color: whiteBackgroundColor,
                icon: const Icon(CupertinoIcons.check_mark),
                onPressed: () async {
                  if (widget.content.tags.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: snackBarColor,
                        content: GlobalText(
                            localizeText: "content_edit_widget_no_tags_error",
                            textSize: 15.0),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    return;
                  }

                  await provider.pvSaveContent(widget.content);

                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TagContainer extends StatelessWidget {
  final String tagName;
  final Function() onPressed;
  final bool isLastButton;

  const TagContainer(
      {super.key,
      required this.tagName,
      required this.onPressed,
      required this.isLastButton});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 5.0),
      child: GestureDetector(
        onTap: onPressed,
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
              child: Row(
                children: [
                  GlobalText(
                    localizeText: tagName,
                    textSize: 13.0,
                    textColor: contentInstanceTagTextColor,
                    isBold: true,
                    localization: false,
                  ),
                  isLastButton ? SizedBox.shrink() : SizedBox(width: 5.0),
                  isLastButton
                      ? SizedBox.shrink()
                      : Text("✕",
                          style: TextStyle(fontSize: 10.0, color: Colors.grey))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
