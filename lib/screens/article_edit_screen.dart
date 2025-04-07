import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/analyze/new_tag_modal.dart';
import 'package:tagify/components/common/tag_container.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class ArticleEditScreen extends StatefulWidget {
  final Article article;
  final List<String>? tagGiven;

  const ArticleEditScreen({super.key, required this.article, this.tagGiven});

  @override
  ArticleEditScreenState createState() => ArticleEditScreenState();
}

class ArticleEditScreenState extends State<ArticleEditScreen> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  String selectedTagName = "";
  String encodedContentList = "";

  late List<String> definedTagList;
  late List<String> newTagList = [];

  @override
  void initState() {
    super.initState();
    definedTagList = widget.tagGiven == null ? [] : widget.tagGiven!;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final provider = Provider.of<TagifyProvider>(context, listen: false);
    final titleController = TextEditingController(text: widget.article.title);
    final bodyController = TextEditingController(text: widget.article.body);

    return Scaffold(
      appBar: AppBar(
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
              if (newTagList.length + definedTagList.length == 0) {
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
              }

              final requestTagsList = newTagList + definedTagList;

              // TODO
              await provider.pvPutArticle(widget.article.id,
                  titleController.text, bodyController.text, requestTagsList);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: mainColor,
              shape: CircleBorder(),
            ),
            child: GlobalText(
              localizeText: "upload_article_screen_upload_button_text",
              textSize: 17.0,
              isBold: true,
              textColor: mainColor,
            ),
          ),
        ],
        title: GlobalText(
          localizeText: "article_edit_screen_edit",
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
                textInputAction: TextInputAction.done,
                style: TextStyle(
                  fontSize: 17.0,
                ),
                decoration: InputDecoration(
                  hintText: tr("article_edit_screen_write_title"),
                  hintStyle: TextStyle(
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
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                      fontSize: 13.0,
                    ),
                    decoration: InputDecoration(
                      hintText: tr("article_edit_screen_write_body"),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // 기존에 선택된 태그 부분
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: GlobalText(
                    localizeText: "article_edit_screen_selected_tag",
                    textSize: 13.0,
                  ),
                ),
              ),
              SizedBox(height: 3.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  definedTagList.length,
                  (index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: TagContainer(
                        tagName: "${definedTagList[index]}",
                        tagColor: isDarkMode
                            ? darkContentInstanceTagTextColor
                            : contentInstanceTagTextColor,
                        isSelected: false,
                        isLastButton: true,
                        textSize: 13.0,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15.0),
              /////////

              // article의 새로 생성되는 tag 부분
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: GlobalText(
                    localizeText: "article_edit_screen_tag_make",
                    textSize: 13.0,
                  ),
                ),
              ),
              SizedBox(height: 3.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  newTagList.length + 1,
                  (index) {
                    if (index >= newTagList.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: TagContainer(
                          tagName: "+",
                          textSize: 13.0,
                          tagColor: Colors.indigoAccent, // TODO
                          isLastButton: true,
                          isSelected: false,
                          onTap: () {
                            if (newTagList.length + definedTagList.length ==
                                3) {
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
                              if (definedTagList.contains(newTagName)) {
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
                        ),
                      );
                    } else {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: TagContainer(
                          tagName: "${newTagList[index]}",
                          tagColor: isDarkMode
                              ? darkContentInstanceTagTextColor
                              : contentInstanceTagTextColor,
                          isSelected: false,
                          isLastButton: true,
                          textSize: 13.0,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
