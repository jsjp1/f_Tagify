import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/components/analyze/new_tag_modal.dart';
import 'package:tagify/components/contents/common.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/utils/util.dart';

class UploadArticleScreen extends StatefulWidget {
  const UploadArticleScreen({super.key});

  @override
  UploadArticleScreenState createState() => UploadArticleScreenState();
}

class UploadArticleScreenState extends State<UploadArticleScreen> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  String selectedTagName = "";
  String encodedContentList = "";
  List<String> newTagList = [];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context);
    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      appBar: AppBar(
        backgroundColor: whiteBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.close),
          highlightColor: Colors.transparent,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (encodedContentList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: snackBarColor,
                    content: GlobalText(
                      localizeText: "upload_article_screen_no_tag_selected",
                      textSize: 15.0,
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
                return;
              } else if (newTagList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: snackBarColor,
                    content: GlobalText(
                      localizeText: "upload_article_screen_no_tag_made",
                      textSize: 15.0,
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
                return;
              }

              await provider.pvPostArticle(titleController.text,
                  bodyController.text, newTagList, encodedContentList);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: mainColor,
              shape: CircleBorder(),
            ),
            child: GlobalText(
              localizeText: "등록",
              textSize: 17.0,
              isBold: true,
              textColor: mainColor,
            ),
          ),
        ],
        title: GlobalText(
          localizeText: "upload_article_screen_upload",
          textSize: 20.0,
          localization: true,
          isBold: true,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              // title 작성 부분
              TextField(
                cursorColor: mainColor,
                controller: titleController,
                autocorrect: false,
                style: TextStyle(
                  fontSize: 17.0,
                ),
                decoration: InputDecoration(
                  hintText: tr("upload_article_screen_write_title"),
                  hintStyle: TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              // body 작성 부분
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.5),
                child: Padding(
                  padding: EdgeInsets.all(3.0),
                  child: TextField(
                    cursorColor: mainColor,
                    controller: bodyController,
                    autocorrect: false,
                    style: TextStyle(
                      fontSize: 13.0,
                    ),
                    decoration: InputDecoration(
                      hintText: tr("upload_article_screen_write_body"),
                      hintStyle: TextStyle(
                        color: Colors.black38,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // 선택해야하는 태그 부분
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: GlobalText(
                    localizeText: "upload_article_screen_tag_select",
                    textSize: 13.0,
                    textColor: Colors.black26,
                  ),
                ),
              ),
              SizedBox(height: 3.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: provider.tags
                      .map(
                        (tag) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: TagContainer(
                            tagName: tag.tagName,
                            tagColor: tag.color,
                            isSelected: tag.tagName == selectedTagName,
                            onTap: () async {
                              setState(() {
                                selectedTagName = tag.tagName;
                              });

                              List<Content> tagContents =
                                  provider.getTagContents(tag.tagName);

                              Map<String, dynamic> contentListMap =
                                  contentListToMap(tagContents);
                              encodedContentList =
                                  encodeTaggedContentsToBase64(contentListMap);
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 20.0),

              // article의 새로 생성되는 tag 부분
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: GlobalText(
                    localizeText: "upload_article_screen_tag_make",
                    textSize: 13.0,
                    textColor: Colors.black26,
                  ),
                ),
              ),
              SizedBox(height: 3.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(newTagList.length + 1, (index) {
                  if (index < newTagList.length) {
                    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: TagContainer(
                            tagName: "${newTagList[index]} ✕", // TODO: x 크기 줄이기
                            isSelected: false,
                            onTap: () {
                              setState(() {
                                newTagList.remove(newTagList[index]);
                              });
                            }));
                  } else {
                    return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: TagContainer(
                          tagName: "+",
                          tagColor: Colors.lightBlue, // TODO
                          isSelected: false,
                          onTap: () {
                            if (newTagList.length == 3) {
                              // 만든 태그가 3개를 초과하려한다면
                              ScaffoldMessenger.of(context).showSnackBar(
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

                            setTagBottomModal(context, (String newTagName) {
                              if (newTagList.contains(newTagName)) {
                                // 이미 만든 태그 이름이라면
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: snackBarColor,
                                    content: GlobalText(
                                        localizeText:
                                            "upload_article_screen_already_exists_tag",
                                        textSize: 15.0),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                return;
                              }
                              setState(
                                () {
                                  newTagList.insert(0, newTagName);
                                },
                              );
                            });
                          },
                        ));
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TagContainer extends StatelessWidget {
  final String tagName;
  final Color? tagColor;
  final bool isSelected;
  final GestureTapCallback onTap;

  const TagContainer({
    super.key,
    required this.tagName,
    this.tagColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: whiteBackgroundColor,
          border: Border.all(
            color: isSelected ? mainColor : contentInstanceTagBorderColor,
            width: isSelected ? 1.7 : 1.5,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: GlobalText(
            localizeText: tagName,
            textSize: 15.0,
            textColor: tagColor ?? Colors.grey,
            isBold: false,
            localization: false,
          ),
        ),
      ),
    );
  }
}
