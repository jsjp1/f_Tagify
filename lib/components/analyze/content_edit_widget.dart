import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/analyze/new_tag_modal.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

import '../common/tag_container.dart';

class ContentEditWidget extends StatefulWidget {
  final bool isLink; // Link 입력하는 모드인지
  final double widgetWidth;
  final bool isEdit;
  Content content;

  ContentEditWidget({
    super.key,
    required this.isLink,
    required this.widgetWidth,
    required this.isEdit,
    required this.content,
  });

  @override
  ContentEditWidgetState createState() => ContentEditWidgetState();
}

class ContentEditWidgetState extends State<ContentEditWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  late List<String> beforeTags; // 수정된 태그 확인하기 위한 리스트

  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();

    titleController.text = widget.content.title;
    descriptionController.text = widget.content.description;

    if (widget.content.tags.length >= 3) {
      // 컨텐츠당 최대 태그 개수 3개로 제한
      widget.content.tags = widget.content.tags.sublist(0, 3);
    }

    beforeTags = List<String>.from(widget.content.tags);
    isBookmarked = widget.content.bookmark;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                      widget.isLink == true
                          ? SizedBox(
                              height: 175.0,
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: CachedNetworkImage(
                                  imageUrl: widget.content.thumbnail,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) {
                                    return SizedBox.expand();
                                  },
                                ),
                              ),
                            )
                          : SizedBox(height: 50.0, child: Container()),
                      Positioned(
                        top: 0.0,
                        right: widget.content.url == "" ? null : 0.0,
                        left: widget.content.url == "" ? -15.0 : null,
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
                  widget.content.url == ""
                      ? const SizedBox.shrink()
                      : const SizedBox(height: 50.0),
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
                        icon: const Icon(CupertinoIcons.clear_circled_solid),
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
                          icon: const Icon(CupertinoIcons.clear_circled_solid),
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
                    height: 21.5,
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
                                  textSize: 13.0,
                                  tagColor: isDarkMode
                                      ? darkContentInstanceTagTextColor
                                      : contentInstanceTagTextColor,
                                  tagName: widget.content.tags[index],
                                  onTap: () {
                                    setState(() {
                                      widget.content.tags.removeAt(index);
                                    });
                                  },
                                  isLastButton: false,
                                );
                              } else {
                                return TagContainer(
                                  textSize: 13.0,
                                  tagName: "+",
                                  tagColor: Colors.indigoAccent,
                                  onTap: () {
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

                  widget.content.title = titleController.text;
                  widget.content.description = descriptionController.text;

                  if (widget.isEdit == true) {
                    // 저장이 아닌 수정 시

                    await provider.pvEditContent(
                        beforeTags, widget.content, widget.content.id);
                  } else {
                    await provider.pvSaveContent(widget.content);
                  }

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
