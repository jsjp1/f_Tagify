import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/analyze/new_tag_modal.dart';
import 'package:tagify/components/common/tag_container.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/utils/smart_network_image.dart';

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
  late FocusNode titleFocusNode;
  late FocusNode descriptionFocusNode;

  List<String> edittedTags = [];

  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();

    titleFocusNode = FocusNode();
    descriptionFocusNode = FocusNode();

    titleController.text = widget.content.title;
    descriptionController.text = widget.content.description;

    if (!widget.isEdit && widget.content.tags.length >= 3) {
      // 컨텐츠당 최대 태그 개수 3개로 제한
      widget.content.tags = widget.content.tags.sublist(0, 3);
    }

    beforeTags = List<String>.from(widget.content.tags);
    edittedTags = List<String>.from(widget.content.tags);
    isBookmarked = widget.content.bookmark;
  }

  @override
  void didUpdateWidget(covariant ContentEditWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLink == true && oldWidget.content != widget.content) {
      titleController.text = widget.content.title;
      descriptionController.text = widget.content.description;

      beforeTags = List<String>.from(widget.content.tags);
      edittedTags = List<String>.from(widget.content.tags);
      isBookmarked = widget.content.bookmark;

      setState(() {});
    }
  }

  void _saveContent() async {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    if (edittedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: snackBarColor,
          content: GlobalText(
              localizeText: "content_edit_widget_no_tags_error",
              textSize: 15.0),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    widget.content.title = titleController.text;
    widget.content.description = descriptionController.text;
    widget.content.tags = edittedTags;
    widget.content.bookmark =
        provider.bookmarkedSet.contains(widget.content.id);

    // 프리미엄 회원 구분
    final newTags = widget.content.tags
        .where((tag) => !provider.tags.any((exist) => exist.tagName == tag))
        .toList();

    final totalTagCount = provider.tags.length + newTags.length;

    if (totalTagCount > nonePremiumTagUpperBound) {
      if (provider.loginResponse!["is_premium"] == false) {
        // 프리미엄 회원이 아니라면
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: snackBarColor,
            content: GlobalText(
                localizeText: "no_premium_tag_count_error", textSize: 15.0),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }
    }

    if (widget.isEdit == true) {
      await provider.pvEditContent(
          beforeTags, widget.content, widget.content.id);
    } else {
      await provider.pvSaveContent(widget.content);
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildEditContent(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return Center(
      child: SizedBox(
        width: widget.widgetWidth * 0.9,
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Stack(
              children: [
                // 썸네일 부분
                (widget.isLink && !widget.isEdit)
                    ? SizedBox(
                        height: 175.0,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: SmartNetworkImage(
                            url: widget.content.thumbnail,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const SizedBox.expand(),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                widget.isEdit
                    ? const SizedBox.shrink()
                    : Positioned(
                        top: 0.0,
                        right: (widget.isLink && !widget.isEdit) ? 0.0 : null,
                        left: (widget.isLink && !widget.isEdit) ? null : -15.0,
                        child: IconButton(
                          highlightColor: Colors.transparent,
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
            widget.isLink && widget.isEdit == false
                ? const SizedBox(height: 50.0)
                : const SizedBox.shrink(),
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
            SizedBox(
              height: 45.0,
              child: TextField(
                controller: titleController,
                focusNode: titleFocusNode,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                autofocus: false,
                style: const TextStyle(fontSize: 17.5),
                cursorColor: mainColor,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      CupertinoIcons.clear_circled_solid,
                      size: 20.0,
                    ),
                    onPressed: () {
                      titleController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  ),
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
            Stack(
              children: [
                TextField(
                  controller: descriptionController,
                  focusNode: descriptionFocusNode,
                  autocorrect: false,
                  autofocus: false,
                  style: const TextStyle(fontSize: 13.0),
                  cursorColor: mainColor,
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                  },
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
                  ),
                  maxLines: 17,
                  minLines: 13,
                  textAlignVertical: TextAlignVertical.top,
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: IconButton(
                    icon: const Icon(
                      CupertinoIcons.clear_circled_solid,
                      size: 20.0,
                    ),
                    onPressed: () {
                      descriptionController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              ],
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
                      edittedTags.length + 1,
                      (index) {
                        if (index < edittedTags.length) {
                          return TagContainer(
                            textSize: 13.0,
                            tagColor: isDarkMode
                                ? darkContentInstanceTagTextColor
                                : contentInstanceTagTextColor,
                            tagName: edittedTags[index],
                            onTap: () {
                              setState(() {
                                edittedTags.removeAt(index);
                              });

                              titleFocusNode.unfocus();
                              descriptionFocusNode.unfocus();
                              FocusScope.of(context).unfocus();
                            },
                            isLastButton: false,
                          );
                        } else {
                          return TagContainer(
                            textSize: 13.0,
                            tagName: "+",
                            tagColor: Colors.indigoAccent,
                            onTap: () {
                              if (provider.loginResponse!["is_premium"] ==
                                  false) {
                                // 프리미엄 회원이 아닌 경우, 컨텐츠당 태그 수 3개로 제한
                                if (edittedTags.length == 3) {
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
                              }

                              // 태그 생성 로직
                              setTagBottomModal(context, (String newTagName) {
                                setState(() {
                                  if (edittedTags.contains(newTagName)) {
                                    return;
                                  }

                                  edittedTags.insert(0, newTagName);
                                });
                              });

                              titleFocusNode.unfocus();
                              descriptionFocusNode.unfocus();
                              FocusScope.of(context).unfocus();
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
            if (widget.isLink && !widget.isEdit) ...[
              const SizedBox(height: 20.0),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * (0.8),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextButton(
                    onPressed: _saveContent,
                    child: GlobalText(
                      localizeText: "content_edit_widget_save_button_text",
                      textSize: 20.0,
                      isBold: true,
                      textColor: whiteBackgroundColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100.0),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLink && !widget.isEdit
        ? SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: _buildEditContent(context),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildEditContent(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextButton(
                        onPressed: _saveContent,
                        child: GlobalText(
                          localizeText: "content_edit_widget_save_button_text",
                          textSize: 20.0,
                          isBold: true,
                          textColor: whiteBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  @override
  void dispose() {
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }
}
