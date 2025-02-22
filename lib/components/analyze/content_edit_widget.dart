import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:tagify/api/content.dart';
import 'package:tagify/global.dart';
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
  late int length;
  late String body;
  late List<dynamic> tags;

  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    url = widget.content["url"];
    thumbnail = widget.content["thumbnail"];
    length = widget.content["video_length"];
    body = widget.content["body"];
    tags = widget.content["tags"];
    widget.titleController.text = widget.content["title"];
    widget.descriptionController.text = widget.content["description"];
  }

  @override
  Widget build(BuildContext context) {
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
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20.0,
          left: 0,
          right: 0,
          child: Center(
            child: IconButton(
              icon: const Icon(CupertinoIcons.add),
              onPressed: () async {
                await saveContent(
                  widget.userId,
                  url,
                  widget.titleController.text,
                  thumbnail,
                  widget.descriptionController.text,
                  isBookmarked,
                  length,
                  body,
                  tags,
                  isVideo(url) ? "video" : "post",
                );

                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}
