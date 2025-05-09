import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/common/delete_alert.dart';
import 'package:tagify/components/common/tag_container.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/content_edit_screen.dart';
import 'package:tagify/utils/smart_network_image.dart';

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
  bool isMemo = false;

  @override
  void initState() {
    super.initState();
    isMemo = widget.content.url == "";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: true);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    isMemo = widget.content.url == "";

    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
      child: Container(
        width: widget.instanceWidth,
        height: isMemo ? widget.instanceHeight * (0.8) : widget.instanceHeight,
        decoration: BoxDecoration(
          color: isDarkMode ? lightBlackBackgroundColor : whiteBackgroundColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? darkContentInstanceBoxShadowColor
                  : contentInstanceBoxShadowColor,
              blurRadius: 5.0,
              spreadRadius: 0.01,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // 컨텐츠 컨테이너 타이틀 바
            SizedBox(
              height: widget.instanceHeight * (0.05),
            ),
            SizedBox(
              height: isMemo
                  ? widget.instanceHeight * (0.2)
                  : widget.instanceHeight * (0.25),
              child: Row(
                children: [
                  SizedBox(width: 10.0),
                  // 왼쪽 아이콘 그룹
                  Row(
                    children: [
                      SizedBox(width: 5.0),
                      SmartNetworkImage(
                        url: widget.content.favicon,
                        height: 17.0,
                        errorWidget: (context, url, error) =>
                            const SizedBox.shrink(),
                      ),
                      widget.content.favicon != ""
                          ? SizedBox(width: 7.0)
                          : SizedBox.shrink(),
                      SizedBox(
                        width: widget.instanceWidth * (0.68),
                        child: GlobalText(
                          localizeText: widget.content.title,
                          textSize: contentInstanceTitleFontSize,
                          isBold: true,
                          overflow: TextOverflow.ellipsis,
                          localization: false,
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
                          icon: Icon(
                              provider.bookmarkedSet.contains(widget.content.id)
                                  ? Icons.bookmark_sharp
                                  : Icons.bookmark_outline_sharp),
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            await provider.pvToggleBookmark(widget.content.id);
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
                          onPressed: () async {
                            await showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              builder: (BuildContext context) {
                                return Wrap(
                                  children: [
                                    widget.content.url != ""
                                        ? Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                5.0, 10.0, 10.0, 0.0),
                                            child: ListTile(
                                              leading: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10.0),
                                                child: Icon(Icons.copy),
                                              ),
                                              title: GlobalText(
                                                localizeText:
                                                    "content_instance_copy_url",
                                                textSize: 17.0,
                                                isBold: true,
                                              ),
                                              onTap: () async {
                                                Navigator.pop(context);

                                                await Clipboard.setData(
                                                  ClipboardData(
                                                      text: widget.content.url),
                                                );

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    duration:
                                                        Duration(seconds: 1),
                                                    backgroundColor:
                                                        snackBarColor,
                                                    content: GlobalText(
                                                      localizeText:
                                                          "content_instance_url_copy_success",
                                                      textSize: 15.0,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          5.0, 10.0, 10.0, 0.0),
                                      child: ListTile(
                                        leading: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Icon(Icons.edit),
                                        ),
                                        title: GlobalText(
                                          localizeText: "content_instance_edit",
                                          textSize: 17.0,
                                          isBold: true,
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);

                                          Navigator.push(
                                            context,
                                            CustomPageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                  secondaryAnimation) {
                                                return ContentEditScreen(
                                                    content: widget.content);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          5.0, 10.0, 10.0, 0.0),
                                      child: ListTile(
                                        leading: Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Icon(CupertinoIcons.delete,
                                              color: mainColor),
                                        ),
                                        title: GlobalText(
                                          localizeText:
                                              "content_instance_delete",
                                          textSize: 17.0,
                                          textColor: mainColor,
                                          isBold: true,
                                        ),
                                        onTap: () async {
                                          bool reallyDelete = false;

                                          String alertMessage =
                                              "content_instance_really_delete_text";
                                          reallyDelete = await showDeleteAlert(
                                              context, alertMessage);

                                          if (reallyDelete == false) {
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                            return;
                                          }

                                          await provider.pvDeleteUserContent(
                                              widget.content.id);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 100.0),
                                  ],
                                );
                              },
                            );
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
              height: isMemo
                  ? widget.instanceHeight * (0.3)
                  : widget.instanceHeight * (0.45),
              child: Row(
                children: [
                  // 컨테이너 상단 좌측 썸네일
                  isMemo
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: SizedBox(
                            height: widget.instanceHeight * (0.38),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey[700]
                                      : contentInstanceNoThumbnailColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? darkContentInstanceBoxShadowColor
                                          : contentInstanceDescriptionColor,
                                      blurRadius: 5.0,
                                      spreadRadius: 1.0,
                                    ),
                                  ],
                                ),
                                // 썸네일 이미지
                                child: SmartNetworkImage(
                                  fit: BoxFit.cover,
                                  url: widget.content.thumbnail,
                                  placeholder: Container(
                                    color: isDarkMode
                                        ? Colors.grey[700]
                                        : contentInstanceNoThumbnailColor,
                                  ),
                                  errorWidget: (context, url, error) {
                                    return Container(
                                      color: isDarkMode
                                          ? Colors.grey[700]
                                          : contentInstanceNoThumbnailColor,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                  SizedBox(
                    width: isMemo
                        ? widget.instanceWidth * (0.95)
                        : widget.instanceWidth * (0.6),
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: SizedBox(
                        height: widget.instanceHeight * (0.4),
                        child: SingleChildScrollView(
                          child: GlobalText(
                            localizeText: widget.content.description,
                            textSize: contentInstanceDescriptionFontSize,
                            localization: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: widget.instanceHeight * (0.05)),
            Center(
              child: SizedBox(
                height: widget.instanceHeight * (0.125),
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.content.tags.length,
                          itemBuilder: (context, index) {
                            return TagContainer(
                              tagName: widget.content.tags[index],
                              textSize: 11.0,
                              tagColor: isDarkMode
                                  ? darkContentInstanceTagTextColor
                                  : contentInstanceTagTextColor,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 15.0, 0.0),
                        child: GlobalText(
                          localizeText: widget.content.createdAt,
                          textSize: 10.0,
                          isBold: true,
                          localization: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
