import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagify/global.dart';
import 'package:tagify/components/contents/content_widget.dart';
import 'package:tagify/provider.dart';

class TagBar extends StatefulWidget {
  final int userId;
  final double tagBarHeight;
  final GlobalKey<ContentWidgetState> contentWidgetKey;

  const TagBar({
    super.key,
    required this.userId,
    required this.contentWidgetKey,
    required this.tagBarHeight,
  });

  @override
  TagBarState createState() => TagBarState();
}

class TagBarState extends State<TagBar> {
  String currentTag = "all";
  List<String> messageList = [];
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    getMessageList();
  }

  void getMessageList() async {
    final prefs = await SharedPreferences.getInstance();
    final beforeLen = messageList.length;

    setState(() {
      messageList = prefs.getStringList("message_list") ?? [];
      if (beforeLen != messageList.length) {
        // 추가된 메시지가 있다면
        isChecked = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TagifyProvider>(context, listen: true);
    getMessageList();

    return Column(
      children: [
        Container(
          color: isDarkMode ? darkNoticeWidgetColor : noticeWidgetColor,
          height: widget.tagBarHeight,
          child: Row(
            children: [
              SizedBox(width: 10.0),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    currentTag = "all";
                  });
                  provider.currentTag = "all";
                },
                child: TagBarContainer(
                  tagName: "tag_bar_tagname_all",
                  tagBarHeight: widget.tagBarHeight,
                  currentSelectedTag: currentTag == "all",
                ),
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    currentTag = "bookmark";
                  });
                  provider.currentTag = "bookmark";
                },
                child: TagBarContainer(
                  tagName: "tag_bar_tagname_bookmark",
                  tagBarHeight: widget.tagBarHeight,
                  currentSelectedTag: currentTag == "bookmark",
                ),
              ),
              // TODO: Future Builder로 태그 추가?
              // 태그에 저장된 이름을 함수에 건네기
              const Expanded(child: SizedBox.shrink()),
              MessageListDialog(
                onCheck: () => setState(() {
                  isChecked = true;
                }),
                messageList: messageList,
                isChecked: isChecked,
              ),
              const SizedBox(width: 20.0),
            ],
          ),
        ),
        Divider(
          color: Colors.grey,
          height: 1,
          thickness: 0.1,
        ),
      ],
    );
  }
}

class TagBarContainer extends StatelessWidget {
  final String tagName;
  final double tagBarHeight;
  final bool currentSelectedTag;

  const TagBarContainer(
      {super.key,
      required this.tagName,
      required this.tagBarHeight,
      required this.currentSelectedTag});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: IntrinsicWidth(
        child: Container(
          height: tagBarHeight * (0.65),
          constraints: BoxConstraints(
            minWidth: 50.0,
            maxWidth: 90.0,
          ),
          decoration: BoxDecoration(
            color: currentSelectedTag
                ? (isDarkMode ? noticeWidgetColor : blackBackgroundColor)
                : (isDarkMode ? darkNoticeWidgetColor : noticeWidgetColor),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(3.0),
              child: GlobalText(
                localizeText: tagName,
                textSize: 12.0,
                textColor: currentSelectedTag
                    ? (isDarkMode ? blackBackgroundColor : whiteBackgroundColor)
                    : (isDarkMode
                        ? whiteBackgroundColor
                        : blackBackgroundColor),
                isBold: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MessageListDialog extends StatelessWidget {
  final VoidCallback onCheck;
  final List<String> messageList;
  final bool isChecked;

  const MessageListDialog(
      {super.key,
      required this.onCheck,
      required this.messageList,
      required this.isChecked});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            onCheck();

            // TODO: 실패 메시지 로그 모달 띄우기
            await showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setStateInDialog) {
                    return ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                        child: AlertDialog(
                          titlePadding:
                              EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
                          surfaceTintColor: Colors.transparent,
                          backgroundColor: isDarkMode
                              ? lightBlackBackgroundColor
                              : whiteBackgroundColor,
                          title: Row(
                            children: [
                              Icon(CupertinoIcons.cube_box),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: GlobalText(
                                  localizeText:
                                      "tag_bar_message_list_title_text",
                                  textSize: 20.0,
                                  letterSpacing: -0.5,
                                  overflow: TextOverflow.fade,
                                  isBold: true,
                                ),
                              ),
                            ],
                          ),
                          content: SizedBox(
                            height: 200.0,
                            width: MediaQuery.of(context).size.width * (0.8),
                            child: messageList.isEmpty
                                ? GlobalText(
                                    localizeText: "tag_bar_no_message_text",
                                    textSize: 17.0,
                                  )
                                : Stack(
                                    children: [
                                      ListView.builder(
                                        itemCount: messageList.length,
                                        itemBuilder: (context, index) {
                                          final List<String> message =
                                              messageList[index].split(" ");

                                          final title = message[0];
                                          final messageBody = message
                                              .sublist(1, message.length - 1)
                                              .join(" ");
                                          final url =
                                              message[message.length - 1];

                                          return Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 25.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      GlobalText(
                                                        localizeText: title,
                                                        textSize: 21.0,
                                                        isBold: true,
                                                        letterSpacing: -0.5,
                                                        localization: true,
                                                      ),
                                                      GlobalText(
                                                        localizeText:
                                                            messageBody
                                                                .toString(),
                                                        textSize: 15.0,
                                                        letterSpacing: -0.5,
                                                        localization: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    messageList.removeAt(index);
                                                    await prefs.setStringList(
                                                        "message_list",
                                                        messageList);

                                                    setStateInDialog(() {});
                                                  },
                                                  child: Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () async {
                                                          await Clipboard
                                                              .setData(
                                                            ClipboardData(
                                                                text: url),
                                                          );

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          1),
                                                              backgroundColor:
                                                                  snackBarColor,
                                                              content:
                                                                  GlobalText(
                                                                localizeText:
                                                                    "content_instance_url_copy_success",
                                                                textSize: 15.0,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Icon(Icons.copy,
                                                            size: 18.0),
                                                      ),
                                                      const SizedBox(
                                                          width: 13.0),
                                                      Icon(Icons.close,
                                                          size: 18.0),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: IgnorePointer(
                                          child: Container(
                                            height: 15.0,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: isDarkMode
                                                    ? [
                                                        lightBlackBackgroundColor,
                                                        lightBlackBackgroundColor
                                                            .withAlpha(0),
                                                      ]
                                                    : [
                                                        Colors.white,
                                                        Colors.white
                                                            .withAlpha(0),
                                                      ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: IgnorePointer(
                                          child: Container(
                                            height: 15.0,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: isDarkMode
                                                    ? [
                                                        lightBlackBackgroundColor,
                                                        lightBlackBackgroundColor
                                                            .withAlpha(0),
                                                      ]
                                                    : [
                                                        Colors.white,
                                                        Colors.white
                                                            .withAlpha(0),
                                                      ],
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
                    );
                  },
                );
              },
            );
          },
          child: Icon(
            CupertinoIcons.cube_box,
            size: 25.0,
          ),
        ),
        if (messageList.isNotEmpty && !isChecked)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
