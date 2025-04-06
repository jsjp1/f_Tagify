import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/components/common/delete_alert.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/content_edit_screen.dart';

import '../common/tag_container.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: true);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
      child: Container(
        width: widget.instanceWidth,
        height: widget.instanceHeight,
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
              height: widget.instanceHeight * (0.25),
              child: Row(
                children: [
                  SizedBox(width: 10.0),
                  // 왼쪽 아이콘 그룹
                  Row(
                    children: [
                      SizedBox(width: 5.0),
                      CachedNetworkImage(
                        imageUrl: widget.content.favicon,
                        height: 17.0,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        errorWidget: (context, url, error) {
                          return SizedBox.shrink();
                        },
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
                                          Navigator.pop(context);

                                          reallyDelete =
                                              await showDeleteAlert(context);

                                          if (reallyDelete == false) {
                                            return;
                                          }

                                          await provider.pvDeleteUserContent(
                                              widget.content.id);
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
              height: widget.instanceHeight * (0.45),
              child: Row(
                children: [
                  // 컨테이너 상단 좌측 썸네일
                  widget.content.url != ""
                      ? Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: SizedBox(
                            height: widget.instanceHeight * (0.38),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
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
                                child: CachedNetworkImage(
                                  imageUrl: widget.content.thumbnail,
                                  fit: BoxFit.cover,
                                  fadeInDuration: Duration.zero,
                                  fadeOutDuration: Duration.zero,
                                  placeholder: (context, url) {
                                    return Container(
                                      color: contentInstanceNoThumbnailColor,
                                      child: Center(
                                        child: Text(
                                          "",
                                          style: TextStyle(fontSize: 30.0),
                                        ),
                                      ),
                                    );
                                  },
                                  errorWidget: (context, url, error) {
                                    return Container(
                                      color: contentInstanceNoThumbnailColor,
                                      child: Center(
                                        child: Text(
                                          "",
                                          style: TextStyle(fontSize: 30.0),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(
                    width: widget.instanceWidth * (0.6),
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: SizedBox(
                        height: widget.instanceHeight * (0.35),
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
                height: widget.instanceHeight * (0.135),
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
