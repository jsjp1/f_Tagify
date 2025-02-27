import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/content.dart';
import 'package:tagify/components/analyze/new_tag_modal.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/utils/util.dart';

class ContentEditWidget extends StatefulWidget {
  final int userId;
  final double widgetWidth;
  final Map<String, dynamic> content;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const ContentEditWidget({
    super.key,
    required this.userId,
    required this.widgetWidth,
    required this.content,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  ContentEditWidgetState createState() => ContentEditWidgetState();
}

class ContentEditWidgetState extends State<ContentEditWidget> {
  late String url;
  late String thumbnail;
  late String favicon;
  late int length;
  late String body;
  late List<dynamic> tags;

  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();

    url = widget.content["url"];
    thumbnail = widget.content["thumbnail"];
    favicon = widget.content["favicon"];
    length = widget.content["video_length"];
    body = widget.content["body"];
    tags = widget.content["tags"];
    if (tags.length > 3) {
      tags = tags.sublist(0, 3);
    }
    widget.titleController.text = widget.content["title"];
    widget.descriptionController.text = widget.content["description"];
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
                      SizedBox(
                        height: 175.0,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: thumbnail.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: thumbnail,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox.expand(),
                        ),
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50.0),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: GlobalText(
                      localizeText: "analyze_screen_title",
                      textSize: 15.0,
                      textColor: analyzeScreenTextColor,
                      isBold: true,
                    ),
                  ),
                  TextField(
                    controller: widget.titleController,
                    style: const TextStyle(fontSize: 17.5),
                    cursorColor: mainColor,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: mainColor),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(CupertinoIcons.delete_left_fill),
                        onPressed: () {
                          widget.titleController.clear();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: GlobalText(
                      localizeText: "analyze_screen_description",
                      textSize: 15.0,
                      textColor: analyzeScreenTextColor,
                      isBold: true,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: widget.descriptionController,
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
                            widget.descriptionController.clear();
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
                            tags.length + 1,
                            (index) {
                              if (index < tags.length && index < 3) {
                                return TagContainer(
                                  tagName: tags[index],
                                  onPressed: () {
                                    setState(() {
                                      tags.removeAt(index);
                                    });
                                  },
                                  isLastButton: false,
                                );
                              } else {
                                return TagContainer(
                                  tagName: "+",
                                  onPressed: () {
                                    if (tags.length == 3) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: snackBarColor,
                                          content: GlobalText(
                                              localizeText:
                                                  "content_edit_widget_no_more_tags_error",
                                              textSize: 15.0),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }

                                    // 태그 생성 로직
                                    setTagBottomModal(context, (String newTag) {
                                      setState(() {
                                        tags.add(newTag);
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
                  if (tags.isEmpty) {
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

                  await saveContent(
                    widget.userId,
                    url,
                    widget.titleController.text,
                    thumbnail,
                    favicon,
                    widget.descriptionController.text,
                    isBookmarked,
                    length,
                    body,
                    tags,
                    isVideo(url) ? "video" : "post",
                  );

                  await provider.fetchContents();
                  await provider.fetchTags();

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
        onTap: isLastButton ? onPressed : () {},
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
                      : GestureDetector(
                          onTap: onPressed,
                          child: Text("✕",
                              style: TextStyle(
                                  fontSize: 10.0, color: Colors.grey)))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
